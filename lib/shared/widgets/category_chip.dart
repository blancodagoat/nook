import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/category_meta.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    required this.onTap,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final meta = CategoryData.getMeta(category);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? meta.color.withOpacity(0.2) : AppColors.glassWhite8,
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
  final String category;
  final double size;

  const CategoryDot({
    super.key,
    required this.category,
    this.size = 8,
  });

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
