import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:nook/core/constants/app_colors.dart';

class LiquidGlassCard extends StatelessWidget {

  const LiquidGlassCard({
    required this.child, super.key,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.tintColor,
    this.blur = 20,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tintColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      shape: LiquidRoundedSuperellipse(borderRadius: radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: tintColor?.withValues(alpha: 0.08) ?? AppColors.glassWhite5,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}

class LiquidGlassLayerWidget extends StatelessWidget {

  const LiquidGlassLayerWidget({
    required this.child, super.key,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      child: child,
    );
  }
}
