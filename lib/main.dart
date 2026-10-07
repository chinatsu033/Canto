import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/gen/app_localizations.dart';
import 'src/controller.dart';
import 'src/source.dart';
import 'src/theme.dart';
import 'ui/player_page.dart';
import 'ui/title_bar.dart';
import 'ui/language.dart';

bool get isDesktop => !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktop) {
    await windowManager.ensureInitialized();
    const opts = WindowOptions(
      size: Size(380, 720),
      minimumSize: Size(320, 560),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: true,
      title: 'Canto',
    );
    await windowManager.waitUntilReadyToShow(opts, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  final controller = CantoController(source: NowPlayingSource.create())
    ..loadPrefs()
    ..start();
  runApp(CantoApp(controller: controller, desktop: isDesktop));
}

const supportedLocales = AppLocalizations.supportedLocales;

Locale localeFromTag(String tag) {
  final p = tag.split('_');
  if (p.length == 3) return Locale.fromSubtags(languageCode: p[0], scriptCode: p[1], countryCode: p[2]);
  if (p.length == 2) return Locale.fromSubtags(languageCode: p[0], scriptCode: p[1]);
  return Locale(p[0]);
}

/// System locale -> one of our locales (Simplified Chinese is the default).
Locale resolveLocale(List<Locale>? locales) {
  for (final l in locales ?? const <Locale>[]) {
    if (l.languageCode == 'zh') {
      if (l.countryCode == 'HK' || l.countryCode == 'MO') return localeFromTag('zh_Hant_HK');
      if (l.scriptCode == 'Hant' || l.countryCode == 'TW') return localeFromTag('zh_Hant');
      return const Locale('zh');
    }
    for (final s in supportedLocales) {
      if (s.languageCode == l.languageCode && s.scriptCode == null && s.countryCode == null) return s;
    }
  }
  return const Locale('zh');
}

class CantoApp extends StatelessWidget {
  final CantoController controller;
  final bool desktop;
  final Locale? locale;
  final ThemeMode themeMode;
  final bool initialLyricsView;
  const CantoApp({
    super.key,
    required this.controller,
    this.desktop = false,
    this.locale,
    this.themeMode = ThemeMode.system,
    this.initialLyricsView = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
        theme: buildTheme(Brightness.light, controller.accent),
        darkTheme: buildTheme(Brightness.dark, controller.accent),
        themeMode: themeMode,
        locale: locale ?? (controller.localeTag == null ? null : localeFromTag(controller.localeTag!)),
        supportedLocales: supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeListResolutionCallback: (locales, supported) => resolveLocale(locales),
        home: Scaffold(
          body: SafeArea(
            child: Column(children: [
              if (desktop)
                DesktopTitleBar(controller: controller)
              else
                Align(alignment: AlignmentDirectional.centerEnd, child: LanguageButton(controller: controller)),
              Expanded(child: PlayerPage(controller: controller, showLyricsView: initialLyricsView)),
            ]),
          ),
        ),
      ),
    );
  }
}
