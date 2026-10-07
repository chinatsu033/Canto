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
  final controller = CantoController(source: NowPlayingSource.create())..start();
  runApp(CantoApp(controller: controller, desktop: isDesktop));
}

const supportedLocales = [
  Locale('zh'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  Locale('ja'),
  Locale('en'),
];

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
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeListResolutionCallback: (locales, supported) {
          for (final l in locales ?? const <Locale>[]) {
            if (l.languageCode == 'zh') {
              final hant = l.scriptCode == 'Hant' || const ['TW', 'HK', 'MO'].contains(l.countryCode);
              return hant ? supportedLocales[1] : supportedLocales[0];
            }
            if (l.languageCode == 'ja') return supportedLocales[2];
            if (l.languageCode == 'en') return supportedLocales[3];
          }
          return supportedLocales[0]; // Simplified Chinese is the default
        },
        home: Scaffold(
          body: SafeArea(
            child: Column(children: [
              if (desktop) const DesktopTitleBar(),
              Expanded(child: PlayerPage(controller: controller, showLyricsView: initialLyricsView)),
            ]),
          ),
        ),
      ),
    );
  }
}
