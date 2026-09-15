import 'package:flutter/material.dart';

/// AppColors: 全局颜色常量定义
/// 遵循设计规范：Lavender & Light Violet 色系
class AppColors {
  /// 紫色主色调 #8B5CF6
  static const Color violet500 = Color(0xFF8B5CF6);

  /// 紫色深色调 #7C3AED
  static const Color violet600 = Color(0xFF7C3AED);

  /// 紫色更深色 #6D28D9
  static const Color violet700 = Color(0xFF6D28D9);

  /// 紫色最深色 #5B21B6
  static const Color violet800 = Color(0xFF5B21B6);

  /// 紫色最深色 #4C1D95
  static const Color violet900 = Color(0xFF4C1D95);

  /// 紫色背景浅色 #F5F3FF
  static const Color violet50 = Color(0xFFF5F3FF);

  /// 紫色背景次浅色 #EDE9FE
  static const Color violet100 = Color(0xFFEDE9FE);

  /// 紫色边框浅色 #DDD6FE
  static const Color violet200 = Color(0xFFDDD6FE);

  /// 紫色中等浅色 #C4B5FD
  static const Color violet300 = Color(0xFFC4B5FD);

  /// 紫色中等色 #A78BFA
  static const Color violet400 = Color(0xFFA78BFA);

  /// 深紫蓝 #312E81
  static const Color indigo900 = Color(0xFF312E81);

  /// 靛蓝色 #4F46E5
  static const Color indigo600 = Color(0xFF4F46E5);

  /// 金色/琥珀色 #FBBF24
  static const Color amber400 = Color(0xFFFBBF24);

  /// 金色深 #F59E0B
  static const Color amber500 = Color(0xFFF59E0B);

  /// 玫瑰色 #F43F5E
  static const Color rose500 = Color(0xFFF43F5E);

  /// 翠绿色 #10B981
  static const Color emerald500 = Color(0xFF10B981);

  /// 蓝色 #3B82F6
  static const Color blue500 = Color(0xFF3B82F6);

  /// 灰色文字 #64748B
  static const Color slate500 = Color(0xFF64748B);

  /// 中灰色文字 #475569
  static const Color slate600 = Color(0xFF475569);

  /// 深灰色文字 #334155
  static const Color slate700 = Color(0xFF334155);

  /// 深色文字 #1E293B
  static const Color slate800 = Color(0xFF1E293B);

  /// 更深文字 #0F172A
  static const Color slate900 = Color(0xFF0F172A);

  /// 最深色背景 #020617
  static const Color slate950 = Color(0xFF020617);

  /// 白色半透明（毛玻璃）rgba(255,255,255,0.88)
  static const Color glassWhite = Color(0xE0FFFFFF);

  /// 紫色半透明边框 rgba(221,214,254,0.65)
  static const Color glassBorder = Color(0xA6DDD6FE);

  /// 毛玻璃背景渐变起始
  static const Color bgGradientStart = Color(0xFFEDE9FE);

  /// 毛玻璃背景渐变中间
  static const Color bgGradientMiddle = Color(0xFFF5F3FF);

  /// 毛玻璃背景渐变结束
  static const Color bgGradientEnd = Color(0xFFE0E7FF);

  /// 渐变列表：背景整体渐变
  static const List<Color> backgroundGradient = [
    bgGradientStart,
    bgGradientMiddle,
    bgGradientEnd,
  ];

  /// 渐变列表：精选比赛卡片深色渐变
  static const List<Color> featuredMatchGradient = [
    Color(0xFF4C1D95),
    Color(0xFF312E81),
    Color(0xFF581C87),
  ];

  /// 渐变列表：个人中心头部渐变
  static const List<Color> profileHeaderGradient = [
    Color(0xFF5B21B6),
    Color(0xFF6B21A8),
    Color(0xFF312E81),
  ];
}
