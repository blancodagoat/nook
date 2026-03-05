import 'package:flutter/material.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/data/models/custom_category.dart';

class CategoryMeta {

  const CategoryMeta({
    required this.emoji,
    required this.color,
    required this.label,
  });
  final String emoji;
  final Color color;
  final String label;
}

class CategoryData {
  static const List<String> expenseCategories = [
    'Food & Drink',
    'Transport',
    'Shopping',
    'Housing',
    'Health',
    'Entertainment',
    'Travel',
    'Education',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Refund',
    'Other',
  ];

  static const Map<String, String> categoryEmojis = {
    'Food & Drink': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Housing': '🏠',
    'Health': '💊',
    'Entertainment': '🎬',
    'Travel': '✈️',
    'Education': '📚',
    'Other': '📦',
    'Salary': '💼',
    'Freelance': '💻',
    'Investment': '📈',
    'Gift': '🎁',
    'Refund': '↩️',
  };

  static CategoryMeta getMeta(String category) {
    final emoji = categoryEmojis[category] ?? '📦';
    final color = AppColors.categoryColors[category] ?? AppColors.catOther;
    return CategoryMeta(
      emoji: emoji,
      color: color,
      label: category,
    );
  }

  static CategoryMeta getCustomCategoryMeta(CustomCategory category) {
    Color color;
    try {
      final r = int.parse(category.colorHex.substring(1, 3), radix: 16);
      final g = int.parse(category.colorHex.substring(3, 5), radix: 16);
      final b = int.parse(category.colorHex.substring(5, 7), radix: 16);
      color = Color.fromARGB(255, r, g, b);
    } catch (e) {
      color = AppColors.catOther;
    }
    
    return CategoryMeta(
      emoji: category.emoji,
      color: color,
      label: category.name,
    );
  }

  static List<String> getAllCategories(String type, List<CustomCategory> customCategories) {
    if (type == 'expense') {
      return getAllExpenseCategories(customCategories);
    } else {
      return getAllIncomeCategories(customCategories);
    }
  }

  static List<String> getAllExpenseCategories(List<CustomCategory> customCategories) {
    final custom = customCategories
        .where((c) => c.type == 'expense')
        .map((c) => c.name)
        .toList();
    return [...expenseCategories, ...custom];
  }

  static List<String> getAllIncomeCategories(List<CustomCategory> customCategories) {
    final custom = customCategories
        .where((c) => c.type == 'income')
        .map((c) => c.name)
        .toList();
    return [...incomeCategories, ...custom];
  }
}
