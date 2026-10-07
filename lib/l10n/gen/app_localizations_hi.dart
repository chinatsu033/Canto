// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Canto';

  @override
  String get nothingPlaying => 'अभी कुछ नहीं चल रहा';

  @override
  String get nothingPlayingHint =>
      'किसी भी म्यूज़िक ऐप में कुछ चलाएँ। Canto सिर्फ़ सिस्टम की ‘अभी चल रहा है’ जानकारी पढ़ता है।';

  @override
  String get loadingLyrics => 'बोल खोजे जा रहे हैं…';

  @override
  String get noLyrics => 'अभी बोल उपलब्ध नहीं';

  @override
  String get plainLyricsNote => 'असिंक्रनाइज़्ड बोल (समय के बिना)';

  @override
  String get lyricsError => 'बोल सेवाओं से कनेक्ट नहीं हो सका';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get play => 'चलाएँ';

  @override
  String get pause => 'रोकें';

  @override
  String get favorite => 'पसंदीदा';

  @override
  String favoriteSent(String app) {
    return '$app को भेजा गया';
  }

  @override
  String get favoriteUnsupported =>
      'यह प्लेयर दूसरे ऐप्स को पसंदीदा जोड़ने नहीं देता';

  @override
  String get favoriteFailed => 'प्लेयर ने अनुरोध अस्वीकार किया';

  @override
  String get controlUnsupported => 'यह प्लेयर रिमोट कंट्रोल स्वीकार नहीं करता';

  @override
  String get upNext => 'आगे';

  @override
  String get alwaysOnTop => 'हमेशा ऊपर';

  @override
  String get minimize => 'छोटा करें';

  @override
  String get close => 'बंद करें';

  @override
  String get back => 'वापस';

  @override
  String get permissionTitle => 'सूचना ऐक्सेस ज़रूरी है';

  @override
  String get permissionBody =>
      'Android दूसरे ऐप्स के मीडिया सेशन सिर्फ़ उन्हीं ऐप्स से साझा करता है जिनके पास सूचना ऐक्सेस है। Canto सिर्फ़ मीडिया जानकारी पढ़ता है, सूचनाओं की सामग्री कभी नहीं।';

  @override
  String get grantPermission => 'सेटिंग खोलें';

  @override
  String get sourceUnavailable =>
      'इस सिस्टम पर ‘अभी चल रहा है’ जानकारी उपलब्ध नहीं';

  @override
  String get resumeFollow => 'मौजूदा पंक्ति पर लौटें';

  @override
  String lyricsFrom(String source) {
    return 'बोल स्रोत: $source';
  }

  @override
  String get seekUnsupported => 'यह प्लेयर आगे-पीछे करने की सुविधा नहीं देता';

  @override
  String get commandFailed => 'प्लेयर ने अनुरोध स्वीकार नहीं किया';

  @override
  String get instrumental => 'वाद्य संगीत';

  @override
  String get translation => 'अनुवाद';

  @override
  String get romanization => 'रोमन लिपि';

  @override
  String get noTranslationHint => 'इस गाने का अभी अनुवाद नहीं है';

  @override
  String get noRomanizationHint => 'इस गाने का अभी रोमन लिप्यंतरण नहीं है';

  @override
  String get autoLabel => 'ऑटो';

  @override
  String get language => 'भाषा';

  @override
  String get followSystem => 'सिस्टम के अनुसार';

  @override
  String get playerActions => 'प्लेयर की कार्रवाइयाँ';

  @override
  String get playerActionsNone => 'यह प्लेयर कोई अतिरिक्त कार्रवाई नहीं देता';

  @override
  String get autoTranslateLabel => 'स्वचालित अनुवाद';

  @override
  String get translatingHint => 'अनुवाद हो रहा है…';

  @override
  String get modelDownloadingHint =>
      'अनुवाद मॉडल डाउनलोड हो रहा है (लगभग 30 MB, केवल पहली बार)…';

  @override
  String get translateQuotaHint =>
      'आज का मुफ़्त अनुवाद कोटा समाप्त हो गया — कल फिर कोशिश करें';

  @override
  String get translateFailedHint => 'स्वचालित अनुवाद विफल रहा';
}
