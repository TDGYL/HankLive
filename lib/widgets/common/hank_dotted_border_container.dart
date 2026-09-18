import 'package:flutter/material.dart';

/// HankDottedBorderContainer: dashlineborderfieldcontainercomponent
/// useuse CustomPaint drawdashlineborderfield，supports rounded corners
/// [child] - childcomponent
/// [color] - dashlinecolor
/// [radius] - corner radius
/// [dashWidth] - dashlinesegment width
/// [dashGap] - dashlinegap width
/// [strokeWidth] - dashlinethickness
class HankDottedBorderContainer extends StatelessWidget {
  /// childcomponent
  final Widget child;

  /// dashlinecolor
  final Color color;

  /// corner radius
  final double radius;

  /// dashlinesegment width
  final double dashWidth;

  /// dashlinegap width
  final double dashGap;

  /// dashlinethickness
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

/// _DottedBorderPainter: dashlineborderfieldpaint
/// in4drawdashline，supports rounded corners
class _DottedBorderPainter extends CustomPainter {
  /// dashlinecolor
  final Color color;

  /// corner radius
  final double radius;

  /// dashlinesegment width
  final double dashWidth;

  /// dashlinegap width
  final double dashGap;

  /// dashlinethickness
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

    // useuse Path draw rounded rectanglepath
    final path = Path()..addRRect(rrect);

    // alongpathdrawdashline
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
