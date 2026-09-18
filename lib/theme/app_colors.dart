import 'package:flutter/material.dart';

/// AppColors: allmatchcolorcommoncountdefines
/// followsetdesign spec：Lavender & Light Violet colorsystem
class AppColors {
  /// purplehomecolorcall #8B5CF6
  static const Color violet500 = Color(0xFF8B5CF6);

  /// purpledarkcolorcall #7C3AED
  static const Color violet600 = Color(0xFF7C3AED);

  /// purplemoredarkcolor #6D28D9
  static const Color violet700 = Color(0xFF6D28D9);

  /// purplemostdarkcolor #5B21B6
  static const Color violet800 = Color(0xFF5B21B6);

  /// purplemostdarkcolor #4C1D95
  static const Color violet900 = Color(0xFF4C1D95);

  /// purplebackgroundlightcolor #F5F3FF
  static const Color violet50 = Color(0xFFF5F3FF);

  /// purplebackgroundtimelightcolor #EDE9FE
  static const Color violet100 = Color(0xFFEDE9FE);

  /// purpleborderfieldlightcolor #DDD6FE
  static const Color violet200 = Color(0xFFDDD6FE);

  /// purpleinetclightcolor #C4B5FD
  static const Color violet300 = Color(0xFFC4B5FD);

  /// purpleinetccolor #A78BFA
  static const Color violet400 = Color(0xFFA78BFA);

  /// deep violet-blue #312E81
  static const Color indigo900 = Color(0xFF312E81);

  /// indigo #4F46E5
  static const Color indigo600 = Color(0xFF4F46E5);

  /// gold/ambercolor #FBBF24
  static const Color amber400 = Color(0xFFFBBF24);

  /// golddark #F59E0B
  static const Color amber500 = Color(0xFFF59E0B);

  /// rosecolor #F43F5E
  static const Color rose500 = Color(0xFFF43F5E);

  /// emeraldcolor #10B981
  static const Color emerald500 = Color(0xFF10B981);

  /// bluecolor #3B82F6
  static const Color blue500 = Color(0xFF3B82F6);

  /// lightgreycolortext #94A3B8
  static const Color slate400 = Color(0xFF94A3B8);

  /// greycolortext #64748B
  static const Color slate500 = Color(0xFF64748B);

  /// medium grey text #475569
  static const Color slate600 = Color(0xFF475569);

  /// dark grey text #334155
  static const Color slate700 = Color(0xFF334155);

  /// darkcolortext #1E293B
  static const Color slate800 = Color(0xFF1E293B);

  /// moredarktext #0F172A
  static const Color slate900 = Color(0xFF0F172A);

  /// darkest background #020617
  static const Color slate950 = Color(0xFF020617);

  /// white translucent（frosted glass）rgba(255,255,255,0.88)
  static const Color glassWhite = Color(0xE0FFFFFF);

  /// purpletranslucentborderfield rgba(221,214,254,0.65)
  static const Color glassBorder = Color(0xA6DDD6FE);

  /// frosted glassbackgroundgradientstart
  static const Color bgGradientStart = Color(0xFFEDE9FE);

  /// frosted glassbackgroundgradientinbetween
  static const Color bgGradientMiddle = Color(0xFFF5F3FF);

  /// frosted glassbackgroundgradientended
  static const Color bgGradientEnd = Color(0xFFE0E7FF);

  /// gradientlist：backgroundoverallbodygradient
  static const List<Color> backgroundGradient = [
    bgGradientStart,
    bgGradientMiddle,
    bgGradientEnd,
  ];

  /// gradientlist：Featuredmatchcarddarkcolorgradient
  static const List<Color> featuredMatchGradient = [
    Color(0xFF4C1D95),
    Color(0xFF312E81),
    Color(0xFF581C87),
  ];

  /// gradientlist：profileheadergradient
  static const List<Color> profileHeaderGradient = [
    Color(0xFF5B21B6),
    Color(0xFF6B21A8),
    Color(0xFF312E81),
  ];
}
