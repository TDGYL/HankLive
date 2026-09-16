import 'package:flutter/material.dart';

/// HankDottedBorderContainer: 虚线边框容器组件
/// 使用 CustomPaint 绘制虚线边框，支持圆角
/// [child] - 子组件
/// [color] - 虚线颜色
/// [radius] - 圆角半径
/// [dashWidth] - 虚线段宽度
/// [dashGap] - 虚线间隔宽度
/// [strokeWidth] - 虚线粗细
class HankDottedBorderContainer extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 虚线颜色
  final Color color;

  /// 圆角半径
  final double radius;

  /// 虚线段宽度
  final double dashWidth;

  /// 虚线间隔宽度
  final double dashGap;

  /// 虚线粗细
  final double strokeWidth;

  HankDottedBorderContainer({
    Key? key,
    required this.child,
    this.color = const Color(0xFFA78BFA),
    this.radius = 16,
    this.dashWidth = 5,
    this.dashGap = 3,
    this.strokeWidth = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        color: color,
        radius: radius,
        dashWidth: dashWidth,
        dashGap: dashGap,
        strokeWidth: strokeWidth,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

/// _DottedBorderPainter: 虚线边框画笔
/// 在矩形四周绘制虚线，支持圆角
class _DottedBorderPainter extends CustomPainter {
  /// 虚线颜色
  final Color color;

  /// 圆角半径
  final double radius;

  /// 虚线段宽度
  final double dashWidth;

  /// 虚线间隔宽度
  final double dashGap;

  /// 虚线粗细
  final double strokeWidth;

  _DottedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.dashGap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    // 使用 Path 绘制圆角矩形路径
    final path = Path()..addRRect(rrect);

    // 沿路径绘制虚线
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
