import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get heroBalance => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1.0,
      );

  static TextStyle get heroAmount => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -2.0,
        height: 1.0,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get cardAmount => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get txAmount => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get title => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get sectionLabel => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      );

  static TextStyle get txTitle => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: 'SF Mono',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get button => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
      );

  static TextStyle get screenTitle => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get sectionHeader => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      );

  static TextStyle get label => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get tabLabel => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get cardAmountSmall => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get miniStatLabel => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get monthSelector => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonText => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get searchPlaceholder => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      );

  static TextStyle get chartLabel => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get chartValue => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get emptyStateTitle => const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get emptyStateSubtitle => const TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
}
