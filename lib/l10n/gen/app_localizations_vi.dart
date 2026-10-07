// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'Không có gì đang phát';

  @override
  String get nothingPlayingHint =>
      'Hãy phát nhạc trong bất kỳ ứng dụng nào. Canto chỉ đọc thông tin đang phát của hệ thống.';

  @override
  String get loadingLyrics => 'Đang tìm lời bài hát…';

  @override
  String get noLyrics => 'Chưa có lời bài hát';

  @override
  String get plainLyricsNote => 'Lời không đồng bộ (không có thời gian)';

  @override
  String get lyricsError => 'Không kết nối được dịch vụ lời bài hát';

  @override
  String get retry => 'Thử lại';

  @override
  String get play => 'Phát';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get favorite => 'Yêu thích';

  @override
  String favoriteSent(String app) {
    return 'Đã gửi tới $app';
  }

  @override
  String get favoriteUnsupported =>
      'Trình phát này không cho ứng dụng khác thêm yêu thích';

  @override
  String get favoriteFailed => 'Trình phát đã từ chối yêu cầu';

  @override
  String get controlUnsupported =>
      'Trình phát này không hỗ trợ điều khiển từ xa';

  @override
  String get upNext => 'Tiếp theo';

  @override
  String get alwaysOnTop => 'Luôn ở trên cùng';

  @override
  String get minimize => 'Thu nhỏ';

  @override
  String get close => 'Đóng';

  @override
  String get back => 'Quay lại';

  @override
  String get permissionTitle => 'Cần quyền truy cập thông báo';

  @override
  String get permissionBody =>
      'Android chỉ chia sẻ phiên phát media của ứng dụng khác với các ứng dụng có quyền truy cập thông báo. Canto chỉ đọc thông tin media, không bao giờ đọc nội dung thông báo.';

  @override
  String get grantPermission => 'Mở cài đặt';

  @override
  String get sourceUnavailable =>
      'Hệ thống này không cung cấp thông tin đang phát';

  @override
  String get resumeFollow => 'Về dòng hiện tại';

  @override
  String lyricsFrom(String source) {
    return 'Lời từ $source';
  }

  @override
  String get seekUnsupported => 'Trình phát này không hỗ trợ tua';

  @override
  String get commandFailed => 'Trình phát không chấp nhận yêu cầu';

  @override
  String get instrumental => 'Nhạc không lời';

  @override
  String get translation => 'Bản dịch';

  @override
  String get romanization => 'Phiên âm Latinh';

  @override
  String get noTranslationHint => 'Bài này chưa có bản dịch';

  @override
  String get noRomanizationHint => 'Bài này chưa có phiên âm';

  @override
  String get autoLabel => 'tự động';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get followSystem => 'Theo hệ thống';

  @override
  String get playerActions => 'Thao tác của trình phát';

  @override
  String get playerActionsNone => 'Trình phát này không có thao tác bổ sung';

  @override
  String get autoTranslateLabel => 'Dịch tự động';

  @override
  String get translatingHint => 'Đang dịch…';

  @override
  String get modelDownloadingHint =>
      'Đang tải mô hình dịch (khoảng 30 MB, chỉ lần đầu)…';

  @override
  String get translateQuotaHint =>
      'Đã hết hạn mức dịch miễn phí hôm nay — hãy thử lại vào ngày mai';

  @override
  String get translateFailedHint => 'Dịch tự động thất bại';
}
