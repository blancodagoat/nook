import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CategoryEmojiCircle extends StatelessWidget {
  final String category;
  final String emoji;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryEmojiCircle({
    super.key,
    required this.category,
    required this.emoji,
    this.size = 46,
    this.isSelected = false,
    this.onTap,
  });

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
            ? (Matrix4.identity()..scale(1.15))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 16 : 12,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
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
