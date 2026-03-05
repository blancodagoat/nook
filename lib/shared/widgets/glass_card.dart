import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nook/core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {

  const GlassCard({
    required this.child, super.key,
    this.padding,
    this.borderRadius = 24,
    this.tintColor,
    this.tintOpacity = 0.0,
    this.hasGlow = false,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? tintColor;
  final double tintOpacity;
  final bool hasGlow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.glassWhite12, AppColors.glassWhite5],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.glassBorder, width: 0.5),
          ),
          child: Stack(
            children: [
              if (tintColor != null)
                Container(
                  color: tintColor!.withValues(alpha: tintOpacity),
                ),
              if (padding != null)
                Padding(
                  padding: padding!,
                  child: child,
                )
              else
                child,
            ],
          ),
        ),
      ),
    );

    if (hasGlow && tintColor != null) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: tintColor!.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
