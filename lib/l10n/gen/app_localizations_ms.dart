// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Tiada apa-apa dimainkan';

  @override
  String get nothingPlayingHint =>
      'Mainkan sesuatu dalam mana-mana aplikasi muzik. Canto hanya membaca maklumat main semasa daripada sistem.';

  @override
  String get loadingLyrics => 'Mencari lirik…';

  @override
  String get noLyrics => 'Belum ada lirik';

  @override
  String get plainLyricsNote => 'Lirik tidak segerak (tanpa masa)';

  @override
  String get lyricsError => 'Tidak dapat menghubungi perkhidmatan lirik';

  @override
  String get retry => 'Cuba lagi';

  @override
  String get play => 'Main';

  @override
  String get pause => 'Jeda';

  @override
  String get favorite => 'Kegemaran';

  @override
  String favoriteSent(String app) {
    return 'Dihantar ke $app';
  }

  @override
  String get favoriteUnsupported =>
      'Pemain ini tidak membenarkan aplikasi lain menambah kegemaran';

  @override
  String get favoriteFailed => 'Pemain menolak permintaan';

  @override
  String get controlUnsupported => 'Pemain ini tidak menerima kawalan jauh';

  @override
  String get upNext => 'Seterusnya';

  @override
  String get alwaysOnTop => 'Sentiasa di atas';

  @override
  String get minimize => 'Kecilkan';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get permissionTitle => 'Akses pemberitahuan diperlukan';

  @override
  String get permissionBody =>
      'Android hanya berkongsi sesi media aplikasi lain dengan aplikasi yang mempunyai akses pemberitahuan. Canto hanya membaca maklumat media, bukan kandungan pemberitahuan.';

  @override
  String get grantPermission => 'Buka tetapan';

  @override
  String get sourceUnavailable => 'Maklumat main semasa tiada pada sistem ini';

  @override
  String get resumeFollow => 'Kembali ke baris semasa';

  @override
  String lyricsFrom(String source) {
    return 'Lirik daripada $source';
  }

  @override
  String get seekUnsupported => 'Pemain ini tidak menyokong anjakan kedudukan';

  @override
  String get commandFailed => 'Pemain tidak menerima permintaan';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get translation => 'Terjemahan';

  @override
  String get romanization => 'Rumi';

  @override
  String get noTranslationHint => 'Lagu ini belum ada terjemahan';

  @override
  String get noRomanizationHint => 'Lagu ini belum ada ejaan rumi';

  @override
  String get autoLabel => 'auto';

  @override
  String get language => 'Bahasa';

  @override
  String get followSystem => 'Ikut sistem';

  @override
  String get playerActions => 'Tindakan pemain';

  @override
  String get playerActionsNone =>
      'Pemain ini tidak menyediakan tindakan tambahan';
}
