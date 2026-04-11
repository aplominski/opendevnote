import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/screens/home_screen.dart';

class OpenDevNoteApp extends ConsumerWidget {
  const OpenDevNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'OpenDevNote',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pl'), Locale('en')],
      locale: locale,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class AppTheme {
  static const _accent = Color(0xFF7C3AED);
  static const _accentLight = Color(0xFFA78BFA);

  static const _lightBg = Color(0xFFFFFFFF);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightText = Color(0xFF37352F);
  static const _lightTextSecondary = Color(0xFF787774);
  static const _lightDivider = Color(0xFFE3E2E0);
  static const _lightHover = Color(0xFFEFefef);

  static const _darkBg = Color(0xFF191919);
  static const _darkSurface = Color(0xFF202020);
  static const _darkText = Color(0xFFE2E0D9);
  static const _darkTextSecondary = Color(0xFF9B9A97);
  static const _darkDivider = Color(0xFF373737);
  static const _darkHover = Color(0xFF2F2F2F);

  static ThemeData lightTheme() {
    return _buildTheme(
      brightness: Brightness.light,
      bg: _lightBg,
      surface: _lightSurface,
      text: _lightText,
      textSecondary: _lightTextSecondary,
      divider: _lightDivider,
      hover: _lightHover,
      accent: _accent,
    );
  }

  static ThemeData darkTheme() {
    return _buildTheme(
      brightness: Brightness.dark,
      bg: _darkBg,
      surface: _darkSurface,
      text: _darkText,
      textSecondary: _darkTextSecondary,
      divider: _darkDivider,
      hover: _darkHover,
      accent: _accentLight,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color textSecondary,
    required Color divider,
    required Color hover,
    required Color accent,
  }) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: Colors.white,
      secondary: accent,
      onSecondary: Colors.white,
      error: const Color(0xFFEB5757),
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: hover,
      onSurfaceVariant: textSecondary,
      outline: divider,
      outlineVariant: divider,
      primaryContainer: isLight
          ? const Color(0xFFF3F0FF)
          : const Color(0xFF2D2640),
      onPrimaryContainer: isLight
          ? const Color(0xFF5B21B6)
          : const Color(0xFFC4B5FD),
      errorContainer: isLight
          ? const Color(0xFFFFE5E5)
          : const Color(0xFF3B1111),
      onErrorContainer: const Color(0xFFEB5757),
      inverseSurface: isLight ? text : surface,
      onInverseSurface: isLight ? surface : text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: textSecondary, size: 20),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        sizeConstraints: const BoxConstraints.tightFor(width: 48, height: 48),
        smallSizeConstraints: const BoxConstraints.tightFor(
          width: 40,
          height: 40,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(borderSide: BorderSide(color: divider)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        hintStyle: TextStyle(
          color: textSecondary.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: text,
          letterSpacing: -0.1,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text,
          letterSpacing: -0.1,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary.withValues(alpha: 0.7),
          height: 1.3,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: divider),
        backgroundColor: Colors.transparent,
        selectedColor: accent.withValues(alpha: 0.08),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: isLight ? text : const Color(0xFF2F2F2F),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: isLight ? surface : text,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 0.5, space: 0),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        dense: true,
        visualDensity: VisualDensity(vertical: -1),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: text,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
    );
  }
}
