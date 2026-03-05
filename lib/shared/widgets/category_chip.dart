import 'package:flutter/material.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/constants/category_meta.dart';

class CategoryChip extends StatelessWidget {

  const CategoryChip({
    required this.category, required this.onTap, super.key,
    this.isSelected = false,
    this.showLabel = true,
  });
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final meta = CategoryData.getMeta(category);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? meta.color.withValues(alpha: 0.2) : AppColors.glassWhite8,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? meta.color : AppColors.glassBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              meta.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? meta.color : AppColors.text100,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CategoryDot extends StatelessWidget {

  const CategoryDot({
    required this.category, super.key,
    this.size = 8,
  });
  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final meta = CategoryData.getMeta(category);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: meta.color,
        shape: BoxShape.circle,
      ),
    );
  }
}
