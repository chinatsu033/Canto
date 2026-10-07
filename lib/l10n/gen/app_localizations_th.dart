// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'ไม่มีเพลงที่กำลังเล่น';

  @override
  String get nothingPlayingHint =>
      'เปิดเพลงในแอปเพลงใดก็ได้ Canto อ่านเฉพาะข้อมูลการเล่นของระบบเท่านั้น';

  @override
  String get loadingLyrics => 'กำลังค้นหาเนื้อเพลง…';

  @override
  String get noLyrics => 'ยังไม่มีเนื้อเพลง';

  @override
  String get plainLyricsNote => 'เนื้อเพลงแบบไม่ซิงก์ (ไม่มีเวลา)';

  @override
  String get lyricsError => 'เชื่อมต่อบริการเนื้อเพลงไม่ได้';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get play => 'เล่น';

  @override
  String get pause => 'หยุดชั่วคราว';

  @override
  String get favorite => 'รายการโปรด';

  @override
  String favoriteSent(String app) {
    return 'ส่งไปยัง $app แล้ว';
  }

  @override
  String get favoriteUnsupported =>
      'เพลเยอร์นี้ไม่อนุญาตให้แอปอื่นเพิ่มรายการโปรด';

  @override
  String get favoriteFailed => 'เพลเยอร์ปฏิเสธคำขอ';

  @override
  String get controlUnsupported => 'เพลเยอร์นี้ไม่รองรับการควบคุมจากระยะไกล';

  @override
  String get upNext => 'ถัดไป';

  @override
  String get alwaysOnTop => 'อยู่บนสุดเสมอ';

  @override
  String get minimize => 'ย่อหน้าต่าง';

  @override
  String get close => 'ปิด';

  @override
  String get back => 'กลับ';

  @override
  String get permissionTitle => 'ต้องการสิทธิ์เข้าถึงการแจ้งเตือน';

  @override
  String get permissionBody =>
      'Android จะแชร์เซสชันสื่อของแอปอื่นเฉพาะกับแอปที่มีสิทธิ์เข้าถึงการแจ้งเตือน Canto อ่านเฉพาะข้อมูลสื่อ ไม่อ่านเนื้อหาการแจ้งเตือน';

  @override
  String get grantPermission => 'เปิดการตั้งค่า';

  @override
  String get sourceUnavailable => 'ระบบนี้ไม่มีข้อมูลการเล่น';

  @override
  String get resumeFollow => 'กลับไปบรรทัดปัจจุบัน';

  @override
  String lyricsFrom(String source) {
    return 'เนื้อเพลงจาก $source';
  }

  @override
  String get seekUnsupported => 'เพลเยอร์นี้ไม่รองรับการเลื่อนตำแหน่ง';

  @override
  String get commandFailed => 'เพลเยอร์ไม่ยอมรับคำขอ';

  @override
  String get instrumental => 'บรรเลง';

  @override
  String get translation => 'คำแปล';

  @override
  String get romanization => 'คำอ่านอักษรโรมัน';

  @override
  String get noTranslationHint => 'เพลงนี้ยังไม่มีคำแปล';

  @override
  String get noRomanizationHint => 'เพลงนี้ยังไม่มีคำอ่านอักษรโรมัน';

  @override
  String get autoLabel => 'อัตโนมัติ';

  @override
  String get language => 'ภาษา';

  @override
  String get followSystem => 'ตามระบบ';

  @override
  String get playerActions => 'การทำงานของเพลเยอร์';

  @override
  String get playerActionsNone => 'เพลเยอร์นี้ไม่มีการทำงานเพิ่มเติม';
}
