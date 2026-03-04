import 'package:flutter/material.dart';
import 'app_colors.dart';

class CategoryMeta {
  final String emoji;
  final Color color;
  final String label;

  const CategoryMeta({
    required this.emoji,
    required this.color,
    required this.label,
  });
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
    return CategoryMeta(emoji: emoji, color: color, label: category);
  }
}
