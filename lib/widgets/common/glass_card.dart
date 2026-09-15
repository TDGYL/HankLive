import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// GlassCard: 毛玻璃卡片容器
/// 实现半透明白色+紫色细边框效果，背景模糊模拟（Flutter 无backdrop则使用实色近似）
class GlassCard extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 圆角
  final double borderRadius;

  /// 背景颜色
  final Color? bgColor;

  /// 边框颜色
  final Color? borderColor;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 点击回调（可空，null则不可点击）
  final VoidCallback? onTap;

  GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 16,
    this.bgColor,
    this.borderColor,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.glassWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A7C3AED),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}
