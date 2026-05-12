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
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leftWidget ?? const SizedBox(),
            middleWidget ?? const SizedBox(),
            rightWidget ?? const SizedBox(),
          ],
        ),
      );
  }
}
