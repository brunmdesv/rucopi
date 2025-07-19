import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_styles.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    canvasColor: AppColors.lightBackground,
    dividerColor: AppColors.lightBorder,
    disabledColor: AppColors.lightDisabled,
    shadowColor: AppColors.lightOverlay,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightAppBar,
      foregroundColor: AppColors.lightPrimary,
      iconTheme: IconThemeData(color: AppColors.lightPrimary),
      elevation: 2,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: AppTextStyles.display,
        fontWeight: AppTextStyles.bold,
        color: AppColors.lightText,
      ),
      headlineLarge: TextStyle(
        fontSize: AppTextStyles.headline,
        fontWeight: AppTextStyles.semiBold,
        color: AppColors.lightText,
      ),
      titleLarge: TextStyle(
        fontSize: AppTextStyles.title,
        fontWeight: AppTextStyles.bold,
        color: AppColors.lightText,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTextStyles.body,
        fontWeight: AppTextStyles.regular,
        color: AppColors.lightText,
      ),
      bodySmall: TextStyle(
        fontSize: AppTextStyles.subtitle,
        fontWeight: AppTextStyles.semiBold,
        color: AppColors.lightSubtitle,
      ),
      labelLarge: TextStyle(
        fontSize: AppTextStyles.button,
        fontWeight: AppTextStyles.bold,
        color: AppColors.lightButtonText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightButton,
        foregroundColor: AppColors.lightButtonText,
        textStyle: const TextStyle(
          fontSize: AppTextStyles.button,
          fontWeight: AppTextStyles.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(color: AppColors.lightPrimary),
        textStyle: const TextStyle(
          fontSize: AppTextStyles.button,
          fontWeight: AppTextStyles.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightButtonText,
      elevation: 4,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.lightPrimary,
      contentTextStyle: TextStyle(
        color: AppColors.lightButtonText,
        fontSize: AppTextStyles.body,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightCard,
      titleTextStyle: const TextStyle(
        fontSize: AppTextStyles.title,
        fontWeight: AppTextStyles.bold,
        color: AppColors.lightText,
      ),
      contentTextStyle: const TextStyle(
        fontSize: AppTextStyles.body,
        color: AppColors.lightText,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.lightError, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      labelStyle: const TextStyle(color: AppColors.lightSubtitle),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      error: AppColors.lightError,
      background: AppColors.lightBackground,
      surface: AppColors.lightCard,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSecondary,
      labelStyle: const TextStyle(color: AppColors.lightText),
      selectedColor: AppColors.lightPrimary.withOpacity(0.2),
      secondarySelectedColor: AppColors.lightPrimary.withOpacity(0.3),
      disabledColor: AppColors.lightDisabled,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    canvasColor: AppColors.darkBackground,
    dividerColor: AppColors.darkBorder,
    disabledColor: AppColors.darkDisabled,
    shadowColor: AppColors.darkOverlay,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkAppBar,
      foregroundColor: AppColors.darkPrimary,
      iconTheme: IconThemeData(color: AppColors.darkPrimary),
      elevation: 2,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: AppTextStyles.display,
        fontWeight: AppTextStyles.bold,
        color: AppColors.darkText,
      ),
      headlineLarge: TextStyle(
        fontSize: AppTextStyles.headline,
        fontWeight: AppTextStyles.semiBold,
        color: AppColors.darkText,
      ),
      titleLarge: TextStyle(
        fontSize: AppTextStyles.title,
        fontWeight: AppTextStyles.bold,
        color: AppColors.darkText,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTextStyles.body,
        fontWeight: AppTextStyles.regular,
        color: AppColors.darkText,
      ),
      bodySmall: TextStyle(
        fontSize: AppTextStyles.subtitle,
        fontWeight: AppTextStyles.semiBold,
        color: AppColors.darkSubtitle,
      ),
      labelLarge: TextStyle(
        fontSize: AppTextStyles.button,
        fontWeight: AppTextStyles.bold,
        color: AppColors.darkButtonText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkButton,
        foregroundColor: AppColors.darkButtonText,
        textStyle: const TextStyle(
          fontSize: AppTextStyles.button,
          fontWeight: AppTextStyles.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkPrimary),
        textStyle: const TextStyle(
          fontSize: AppTextStyles.button,
          fontWeight: AppTextStyles.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkButtonText,
      elevation: 4,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.darkPrimary,
      contentTextStyle: TextStyle(
        color: AppColors.darkButtonText,
        fontSize: AppTextStyles.body,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCard,
      titleTextStyle: const TextStyle(
        fontSize: AppTextStyles.title,
        fontWeight: AppTextStyles.bold,
        color: AppColors.darkText,
      ),
      contentTextStyle: const TextStyle(
        fontSize: AppTextStyles.body,
        color: AppColors.darkText,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.darkError, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      labelStyle: const TextStyle(color: AppColors.darkSubtitle),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      error: AppColors.darkError,
      background: AppColors.darkBackground,
      surface: AppColors.darkCard,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSecondary,
      labelStyle: const TextStyle(color: AppColors.darkText),
      selectedColor: AppColors.darkPrimary.withOpacity(0.2),
      secondarySelectedColor: AppColors.darkPrimary.withOpacity(0.3),
      disabledColor: AppColors.darkDisabled,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
    ),
  );

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_themeKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(_themeKey, 'dark');
        break;
      case ThemeMode.system:
      default:
        await prefs.setString(_themeKey, 'system');
    }
  }

  void toggleTheme(bool isDark) {
    setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);
    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
