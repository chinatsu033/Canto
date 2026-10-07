// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Tidak ada yang diputar';

  @override
  String get nothingPlayingHint =>
      'Putar sesuatu di aplikasi musik apa pun. Canto hanya membaca info pemutaran dari sistem.';

  @override
  String get loadingLyrics => 'Mencari lirik…';

  @override
  String get noLyrics => 'Belum ada lirik';

  @override
  String get plainLyricsNote => 'Lirik tidak sinkron (tanpa waktu)';

  @override
  String get lyricsError => 'Tidak dapat menghubungi layanan lirik';

  @override
  String get retry => 'Coba lagi';

  @override
  String get play => 'Putar';

  @override
  String get pause => 'Jeda';

  @override
  String get favorite => 'Favorit';

  @override
  String favoriteSent(String app) {
    return 'Terkirim ke $app';
  }

  @override
  String get favoriteUnsupported =>
      'Pemutar ini tidak mengizinkan aplikasi lain menambah favorit';

  @override
  String get favoriteFailed => 'Pemutar menolak permintaan';

  @override
  String get controlUnsupported =>
      'Pemutar ini tidak menerima kontrol jarak jauh';

  @override
  String get upNext => 'Berikutnya';

  @override
  String get alwaysOnTop => 'Selalu di atas';

  @override
  String get minimize => 'Perkecil';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get permissionTitle => 'Perlu akses notifikasi';

  @override
  String get permissionBody =>
      'Android hanya membagikan sesi media aplikasi lain kepada aplikasi yang punya akses notifikasi. Canto hanya membaca info media, tidak pernah isi notifikasi.';

  @override
  String get grantPermission => 'Buka setelan';

  @override
  String get sourceUnavailable => 'Info pemutaran tidak tersedia di sistem ini';

  @override
  String get resumeFollow => 'Kembali ke baris saat ini';

  @override
  String lyricsFrom(String source) {
    return 'Lirik dari $source';
  }

  @override
  String get seekUnsupported =>
      'Pemutar ini tidak mendukung penggeseran posisi';

  @override
  String get commandFailed => 'Pemutar tidak menerima permintaan';

  @override
  String get instrumental => 'Instrumental';

  @override
  String get translation => 'Terjemahan';

  @override
  String get romanization => 'Romanisasi';

  @override
  String get noTranslationHint => 'Lagu ini belum punya terjemahan';

  @override
  String get noRomanizationHint => 'Lagu ini belum punya romanisasi';

  @override
  String get autoLabel => 'otomatis';

  @override
  String get language => 'Bahasa';

  @override
  String get followSystem => 'Ikuti sistem';

  @override
  String get playerActions => 'Aksi pemutar';

  @override
  String get playerActionsNone => 'Pemutar ini tidak menyediakan aksi tambahan';
}
