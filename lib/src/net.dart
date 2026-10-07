import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'lrclib.dart' show userAgent;

typedef Sleeper = Future<void> Function(Duration);

class RateLimited implements Exception {
  final String host;
  RateLimited(this.host);
  @override
  String toString() => 'RateLimited($host)';
}

/// Shared HTTP gate for lyric sources:
/// * every request carries an identifying User-Agent (plus X-User-Agent for
///   environments that can't set UA),
/// * requests are strictly sequential (one in flight at a time),
/// * optional minimum spacing per host (LrcShare: 300 ms),
/// * HTTP 429 -> exponential backoff (1 s, 2 s, 4 s … or Retry-After), never an
///   immediate retry; after [maxRetries] the host is cooled down and skipped.
/// URLs are never decorated with cache-busting parameters.
class HttpGate {
  final http.Client client;
  final Sleeper sleep;
  final DateTime Function() now;
  final int maxRetries;
  final Map<String, Duration> minSpacing;
  final _last = <String, DateTime>{};
  final _cooldownUntil = <String, DateTime>{};
  final _backoffLevel = <String, int>{};
  Future<void> _tail = Future.value();

  HttpGate({
    http.Client? client,
    Sleeper? sleep,
    DateTime Function()? now,
    this.maxRetries = 2,
    this.minSpacing = const {'api.lrcshare.com': Duration(milliseconds: 300)},
  })  : client = client ?? http.Client(),
        sleep = sleep ?? ((d) => Future<void>.delayed(d)),
        now = now ?? DateTime.now;

  static Map<String, String> get headers => {'User-Agent': userAgent, 'X-User-Agent': userAgent, 'Lrclib-Client': userAgent};

  /// Serialises calls so no two lyric requests run in parallel.
  Future<http.Response> get(Uri uri) {
    final c = Completer<http.Response>();
    _tail = _tail.then((_) async {
      try {
        c.complete(await _get(uri));
      } catch (e, st) {
        c.completeError(e, st);
      }
    });
    return c.future;
  }

  Future<http.Response> _get(Uri uri) async {
    final host = uri.host;
    final cd = _cooldownUntil[host];
    if (cd != null && now().isBefore(cd)) throw RateLimited(host);
    for (var attempt = 0;; attempt++) {
      final gap = minSpacing[host];
      final last = _last[host];
      if (gap != null && last != null) {
        final wait = gap - now().difference(last);
        if (wait > Duration.zero) await sleep(wait);
      }
      _last[host] = now();
      final r = await client.get(uri, headers: headers).timeout(const Duration(seconds: 12));
      _last[host] = now();
      if (r.statusCode != 429) {
        _backoffLevel[host] = 0;
        return r;
      }
      final level = (_backoffLevel[host] ?? 0);
      _backoffLevel[host] = level + 1;
      final retryAfter = int.tryParse(r.headers['retry-after'] ?? '');
      final delay = retryAfter != null ? Duration(seconds: retryAfter) : Duration(seconds: pow(2, level).toInt());
      if (attempt >= maxRetries) {
        _cooldownUntil[host] = now().add(delay * 2);
        throw RateLimited(host);
      }
      await sleep(delay);
    }
  }
}
