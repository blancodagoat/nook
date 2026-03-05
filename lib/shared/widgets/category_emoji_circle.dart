import 'package:flutter/material.dart';
import 'package:nook/core/constants/app_colors.dart';

class CategoryEmojiCircle extends StatelessWidget {

  const CategoryEmojiCircle({
    required this.category, required this.emoji, super.key,
    this.size = 46,
    this.isSelected = false,
    this.onTap,
  });
  final String category;
  final String emoji;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        transform: isSelected
            ? Matrix4.diagonal3Values(1.15, 1.15, 1)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 16 : 12,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.48),
          ),
        ),
      ),
    );
  }
}
