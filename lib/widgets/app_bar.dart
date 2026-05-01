import 'package:flutter/material.dart';
import '../brand_config.dart';
import 'stitched_container.dart';

class ReusableAppBar extends StatelessWidget {
  final Widget? leftWidget;
  final Widget? middleWidget;
  final Widget? rightWidget;

  const ReusableAppBar({
    super.key,
    this.leftWidget,
    this.middleWidget,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DashedBorderPainter(
        color: BrandColors.primary,
        strokeWidth: 2,
        gap: 6,
        dashWidth: 8,
        borderRadius: 32,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: BrandColors.tertiary.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: BrandColors.primary.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leftWidget ?? const SizedBox(),
            middleWidget ?? const SizedBox(),
            rightWidget ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
