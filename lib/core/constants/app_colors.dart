import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0A0A0F);
  static const surface0 = Color(0xFF111114);
  static const surface1 = Color(0xFF13131A);
  static const surface2 = Color(0xFF1C1C26);
  static const surface3 = Color(0xFF252533);

  static const voidBlack = Color(0xFF000000);
  static const abyss = Color(0xFF080808);
  static const depth = Color(0xFF0D0D0F);

  static const accent = Color(0xFF5B6EF5);
  static const accentSoft = Color(0x1A5B6EF5);

  static const positive = Color(0xFF06D6A0);
  static const positiveSoft = Color(0x1506D6A0);
  static const negative = Color(0xFFFF4757);
  static const negativeSoft = Color(0x15FF4757);
  static const warning = Color(0xFFFFB627);

  static const frost12 = Color(0x1FFFFFFF);
  static const frost06 = Color(0x0FFFFFFF);
  static const frostBorder = Color(0x18FFFFFF);

  static const textPrimary = Color(0xFFF5F5FA);
  static const textSecondary = Color(0xFF8E8EA8);
  static const textTertiary = Color(0xFF4A4A62);

  static const catFood = Color(0xFFFF6B6B);
  static const catTransport = Color(0xFF4CC9F0);
  static const catShopping = Color(0xFFFFBE0B);
  static const catHousing = Color(0xFF8338EC);
  static const catHealth = Color(0xFF06D6A0);
  static const catEntertainment = Color(0xFFF72585);
  static const catTravel = Color(0xFF3A86FF);
  static const catEducation = Color(0xFFFF9F1C);
  static const catSalary = Color(0xFF06D6A0);
  static const catFreelance = Color(0xFF4CC9F0);
  static const catInvestment = Color(0xFF8338EC);
  static const catOther = Color(0xFF6B7280);
  static const catGift = Color(0xFFF72585);
  static const catRefund = Color(0xFF4CC9F0);

  static const Map<String, Color> categoryColors = {
    'Food & Drink': catFood,
    'Transport': catTransport,
    'Shopping': catShopping,
    'Housing': catHousing,
    'Health': catHealth,
    'Entertainment': catEntertainment,
    'Travel': catTravel,
    'Education': catEducation,
    'Salary': catSalary,
    'Freelance': catFreelance,
    'Investment': catInvestment,
    'Gift': catGift,
    'Refund': catRefund,
    'Other': catOther,
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? catOther;
  }

  static const glassWhite5 = Color(0x0DFFFFFF);
  static const glassWhite8 = Color(0x14FFFFFF);
  static const glassWhite12 = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x18FFFFFF);

  static const incomeA = positive;
  static const incomeB = Color(0xFF00D4FF);
  static const expenseA = negative;
  static const expenseB = Color(0xFFFF8C42);
  static const accentA = accent;
  static const accentB = Color(0xFFBF5FFF);

  static const text100 = textPrimary;
  static const text80 = Color(0xCCFFFFFF);
  static const text50 = textSecondary;
  static const text30 = textTertiary;
}
