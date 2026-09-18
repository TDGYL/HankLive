import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// GlassCard: frosted glasscardcontainer
/// semi-transparent white+purpleborderfieldeffectif，backgroundmodeblurmodesimulate（Flutter nonebackdropthenuseuseentitycolorapproximation）
class GlassCard extends StatelessWidget {
  /// childcomponent
  final Widget child;

  /// innerborderdistance
  final EdgeInsetsGeometry padding;

  /// rounded
  final double borderRadius;

  /// backgroundcolor
  final Color? bgColor;

  /// borderfieldcolor
  final Color? borderColor;

  /// outer margin
  final EdgeInsetsGeometry? margin;

  /// tapcallback（canempty，nullthennotcantap）
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
