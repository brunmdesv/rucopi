import 'package:flutter/material.dart';

class AppColors {
  // Tema Claro
  static const Color lightPrimary = Color(0xFF606A45);
  static const Color lightSecondary = Color(0xFFD0B081);
  static const Color lightBackground = Color(0xFFF8F6F2);
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF222222);
  static const Color lightSubtitle = Color(0xFF606A45);
  static const Color lightButton = Color(0xFF606A45);
  static const Color lightButtonText = Colors.white;
  static const Color lightAppBar = Color(0xFFD0B081);
  static const Color lightError = Color(0xFFD32F2F);
  static const Color lightSuccess = Color(0xFF388E3C);
  static const Color lightWarning = Color(0xFFFBC02D);
  static const Color lightInfo = Color(0xFF1976D2);
  static const Color lightDisabled = Color(0xFFBDBDBD);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightOverlay = Color(0x0F000000);

  // Tema Escuro
  static const Color darkPrimary = Color(0xFF8DA34E);
  static const Color darkSecondary = Color(0xFF191919);
  static const Color darkBackground = Color(0xFF191919);
  static const Color darkCard = Color(0xFF232323);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkSubtitle = Color(0xFF8DA34E);
  static const Color darkButton = Color(0xFF8DA34E);
  static const Color darkButtonText = Color(0xFF191919);
  static const Color darkAppBar = Color(0xFF191919);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkSuccess = Color(0xFF81C784);
  static const Color darkWarning = Color(0xFFFFF176);
  static const Color darkInfo = Color(0xFF64B5F6);
  static const Color darkDisabled = Color(0xFF616161);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkOverlay = Color(0x1AFFFFFF);

  // Gradientes
  static const Gradient lightGradient = LinearGradient(
    colors: [lightPrimary, lightSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient darkGradient = LinearGradient(
    colors: [darkPrimary, darkSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextStyles {
  static const double display = 32;
  static const double headline = 26;
  static const double title = 22;
  static const double subtitle = 16;
  static const double body = 14;
  static const double caption = 12;
  static const double button = 16;

  static const FontWeight bold = FontWeight.bold;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight light = FontWeight.w300;
}

class AppRadius {
  static const double card = 20;
  static const double button = 16;
  static const double field = 14;
  static const double chip = 12;
  static const double avatar = 32;
}

class AppSpacing {
  static const double page = 24;
  static const double section = 16;
  static const double item = 8;
  static const double tiny = 4;
}

class AppShadows {
  static const List<BoxShadow> light = [
    BoxShadow(
      color: AppColors.lightOverlay,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> dark = [
    BoxShadow(
      color: AppColors.darkOverlay,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
