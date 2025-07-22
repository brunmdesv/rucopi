import 'package:flutter/material.dart';

class AppColors {
  // Tema Claro
  static const Color lightPrimary = Color(0xFF002E34); // detalhes
  static const Color lightBackground = Color(0xFFf8f8f8); // fundo
  static const Color lightCard = Color(0xFFf8f8f8);
  static const Color lightText = Color(0xFF002E34);
  static const Color lightButton = Color(0xFF002E34);
  static const Color lightButtonText = Color(0xFFf8f8f8);
  static const Color lightAppBar = Color(0xFFf8f8f8);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightDisabled = Color(0xFFBDBDBD);
  static const Color lightBorder = Color(0xFF002E34);
  static const Color lightOverlay = Color(0x0F002E34);
  
  // Tema Escuro
  static const Color darkPrimary = Color(0xFFf8f8f8); // detalhes
  static const Color darkBackground = Color(0xFF181619); // fundo
  static const Color darkCard = Color(0xFF181619);
  static const Color darkText = Color(0xFFf8f8f8);
  static const Color darkButton = Color(0xFFf8f8f8);
  static const Color darkButtonText = Color(0xFF181619);
  static const Color darkAppBar = Color(0xFF181619);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkDisabled = Color(0xFF616161);
  static const Color darkBorder = Color(0xFFf8f8f8);
  static const Color darkOverlay = Color(0x1A00C16C);
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
