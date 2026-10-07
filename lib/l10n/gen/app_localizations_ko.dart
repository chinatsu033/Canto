// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => '재생 중인 항목이 없습니다';

  @override
  String get nothingPlayingHint =>
      '아무 음악 앱에서나 재생해 보세요. Canto는 시스템의 재생 정보만 읽습니다.';

  @override
  String get loadingLyrics => '가사를 찾는 중…';

  @override
  String get noLyrics => '아직 가사가 없습니다';

  @override
  String get plainLyricsNote => '싱크 없는 가사(타이밍 없음)';

  @override
  String get lyricsError => '가사 서비스에 연결할 수 없습니다';

  @override
  String get retry => '다시 시도';

  @override
  String get play => '재생';

  @override
  String get pause => '일시정지';

  @override
  String get favorite => '즐겨찾기';

  @override
  String favoriteSent(String app) {
    return '$app(으)로 보냈습니다';
  }

  @override
  String get favoriteUnsupported => '이 플레이어는 다른 앱에서 즐겨찾기를 추가할 수 없습니다';

  @override
  String get favoriteFailed => '플레이어가 요청을 거부했습니다';

  @override
  String get controlUnsupported => '이 플레이어는 원격 제어를 지원하지 않습니다';

  @override
  String get upNext => '다음 곡';

  @override
  String get alwaysOnTop => '항상 위에 표시';

  @override
  String get minimize => '최소화';

  @override
  String get close => '닫기';

  @override
  String get back => '뒤로';

  @override
  String get permissionTitle => '알림 접근 권한이 필요합니다';

  @override
  String get permissionBody =>
      'Android는 알림 접근 권한이 있는 앱에만 다른 앱의 미디어 세션을 공유합니다. Canto는 미디어 정보만 읽으며 알림 내용은 읽지 않습니다.';

  @override
  String get grantPermission => '설정 열기';

  @override
  String get sourceUnavailable => '이 시스템에서는 재생 정보를 가져올 수 없습니다';

  @override
  String get resumeFollow => '현재 줄로 돌아가기';

  @override
  String lyricsFrom(String source) {
    return '가사 제공: $source';
  }

  @override
  String get seekUnsupported => '이 플레이어는 탐색을 지원하지 않습니다';

  @override
  String get commandFailed => '플레이어가 요청을 받아들이지 않았습니다';

  @override
  String get instrumental => '연주곡';

  @override
  String get translation => '번역';

  @override
  String get romanization => '로마자';

  @override
  String get noTranslationHint => '이 곡은 아직 번역이 없습니다';

  @override
  String get noRomanizationHint => '이 곡은 아직 로마자 표기가 없습니다';

  @override
  String get autoLabel => '자동';

  @override
  String get language => '언어';

  @override
  String get followSystem => '시스템 설정 따르기';

  @override
  String get playerActions => '플레이어 동작';

  @override
  String get playerActionsNone => '이 플레이어는 추가 동작을 제공하지 않습니다';
}
