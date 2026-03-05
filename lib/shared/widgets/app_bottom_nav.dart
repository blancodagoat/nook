import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/constants/app_text_styles.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex, required this.onTap, super.key,
  });
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(
              top: 8,
              bottom: bottomPadding + 8,
            ),
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: Color(0xD90A0A0F),
              border: Border(
                top: BorderSide(color: AppColors.frostBorder, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                _TabItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  current: currentIndex,
                  onTap: onTap,
                ),
                _TabItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'History',
                  index: 1,
                  current: currentIndex,
                  onTap: onTap,
                ),
                _TabItem(
                  icon: Icons.analytics_rounded,
                  label: 'Summary',
                  index: 2,
                  current: currentIndex,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  bool get isActive => index == current;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: 2,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.accent : AppColors.textTertiary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.accent : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
