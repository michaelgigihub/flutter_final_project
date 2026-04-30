import 'package:flutter/material.dart';
import 'dart:ui';
import '../brand_config.dart';

class StitchedContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double shadowOffset;
  final bool showShadow;

  const StitchedContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.shadowOffset = 6.0,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? BrandColors.neutral,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: BrandColors.primary.withOpacity(0.4),
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: BrandColors.primary,
          strokeWidth: 2,
          dashWidth: 8,
          gap: 6,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashWidth;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.dashWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);

    PathMetrics pathMetrics = path.computeMetrics();
    Path dashedPath = Path();

    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += gap;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
