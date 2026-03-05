import 'package:flutter/material.dart';
import 'package:nook/core/constants/app_colors.dart';

class NookCard extends StatelessWidget {

  const NookCard({
    required this.child, super.key,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.tint,
    this.hasBorder = true,
    this.onTap,
    this.backgroundColor,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;
  final bool hasBorder;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (tint != null
                   ? Color.alphaBlend(tint!.withValues(alpha: 0.06), AppColors.surface1)
                  : AppColors.surface1),
          borderRadius: BorderRadius.circular(radius),
          border: hasBorder
              ? Border.all(color: AppColors.frostBorder, width: 0.75)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(radius)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
