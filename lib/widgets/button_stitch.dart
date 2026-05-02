import 'package:flutter/material.dart';
import '../brand_config.dart';
import 'stitched_container.dart';

class ButtonStitch extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ButtonStitch({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.primary : BrandColors.neutral,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: BrandColors.natureGreen.withValues(alpha: 0.2), 
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  )
                ]
              : null,
        ),
        child: CustomPaint(
          foregroundPainter: DashedBorderPainter(
            color: isSelected ? BrandColors.natureGreen : BrandColors.primary,
            strokeWidth: 2,
            dashWidth: 8,
            gap: 6,
            borderRadius: 16,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: BrandTypography.labelMd.copyWith(
                    color: isSelected ? BrandColors.secondary : BrandColors.natureGreen,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
