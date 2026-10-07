// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'لا يوجد تشغيل حاليًا';

  @override
  String get nothingPlayingHint =>
      'شغّل أي شيء في أي تطبيق موسيقى. يقرأ Canto معلومات التشغيل من النظام فقط.';

  @override
  String get loadingLyrics => 'جارٍ البحث عن الكلمات…';

  @override
  String get noLyrics => 'لا توجد كلمات بعد';

  @override
  String get plainLyricsNote => 'كلمات غير متزامنة (بدون توقيت)';

  @override
  String get lyricsError => 'تعذّر الوصول إلى خدمات الكلمات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get favorite => 'المفضلة';

  @override
  String favoriteSent(String app) {
    return 'تم الإرسال إلى $app';
  }

  @override
  String get favoriteUnsupported =>
      'لا يسمح هذا المشغّل للتطبيقات الأخرى بإضافة المفضلة';

  @override
  String get favoriteFailed => 'رفض المشغّل الطلب';

  @override
  String get controlUnsupported => 'لا يقبل هذا المشغّل التحكم عن بُعد';

  @override
  String get upNext => 'التالي';

  @override
  String get alwaysOnTop => 'فوق كل النوافذ';

  @override
  String get minimize => 'تصغير';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get permissionTitle => 'يلزم الوصول إلى الإشعارات';

  @override
  String get permissionBody =>
      'لا يشارك Android جلسات الوسائط الخاصة بالتطبيقات الأخرى إلا مع التطبيقات التي لديها إذن الوصول إلى الإشعارات. يقرأ Canto معلومات الوسائط فقط ولا يقرأ محتوى الإشعارات أبدًا.';

  @override
  String get grantPermission => 'فتح الإعدادات';

  @override
  String get sourceUnavailable => 'معلومات التشغيل غير متاحة على هذا النظام';

  @override
  String get resumeFollow => 'العودة إلى السطر الحالي';

  @override
  String lyricsFrom(String source) {
    return 'الكلمات من $source';
  }

  @override
  String get seekUnsupported => 'لا يدعم هذا المشغّل تغيير موضع التشغيل';

  @override
  String get commandFailed => 'لم يقبل المشغّل الطلب';

  @override
  String get instrumental => 'موسيقى بدون غناء';

  @override
  String get translation => 'الترجمة';

  @override
  String get romanization => 'الكتابة بالحروف اللاتينية';

  @override
  String get noTranslationHint => 'لا توجد ترجمة لهذه الأغنية بعد';

  @override
  String get noRomanizationHint => 'لا توجد كتابة لاتينية لهذه الأغنية بعد';

  @override
  String get autoLabel => 'تلقائي';

  @override
  String get language => 'اللغة';

  @override
  String get followSystem => 'حسب النظام';

  @override
  String get playerActions => 'إجراءات المشغّل';

  @override
  String get playerActionsNone => 'لا يوفّر هذا المشغّل إجراءات إضافية';

  @override
  String get autoTranslateLabel => 'ترجمة تلقائية';

  @override
  String get translatingHint => 'جارٍ الترجمة…';

  @override
  String get modelDownloadingHint =>
      'جارٍ تنزيل نموذج الترجمة (حوالي 30 ميغابايت، للمرة الأولى فقط)…';

  @override
  String get translateQuotaHint =>
      'نفدت حصة الترجمة المجانية لليوم — حاول غدًا';

  @override
  String get translateFailedHint => 'فشلت الترجمة التلقائية';
}
