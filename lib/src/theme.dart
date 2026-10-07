import 'package:flutter/material.dart';
import 'palette.dart';

const lightBg = Color(0xFFFFFFFF);
const lightCard = Color(0xFFF3F4F6);
const darkBg = Color(0xFF1F1F1F);
const darkCard = Color(0xFF2A2A2A);
const controlRadius = 16.0; // all controls: rounded squares, never circles
const cardRadius = 24.0;

ThemeData buildTheme(Brightness b, Color? artworkColor) {
  final accent = readableAccent(artworkColor ?? fallbackAccent, b);
  final light = b == Brightness.light;
  final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: b).copyWith(
    primary: accent,
    surface: light ? lightBg : darkBg,
    surfaceContainer: light ? lightCard : darkCard,
    surfaceContainerHighest: light ? const Color(0xFFE8EAED) : const Color(0xFF353535),
    onSurface: light ? const Color(0xFF202124) : const Color(0xFFE8EAED),
    onSurfaceVariant: light ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
  );
  final square = RoundedRectangleBorder(borderRadius: BorderRadius.circular(controlRadius));
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: 'Roboto',
    fontFamilyFallback: const ['Noto Sans CJK SC', 'Noto Sans SC', 'PingFang SC', 'Microsoft YaHei', 'Hiragino Sans'],
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      margin: EdgeInsets.zero,
    ),
    iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(shape: square)),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: square, elevation: 0)),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: square)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: square)),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(controlRadius)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius))),
    ),
    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
  );
}
