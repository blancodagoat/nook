import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientUtils {
  static Widget meshBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentA.withOpacity(0.15),
                  Colors.transparent,
                ],
                radius: 1.0,
              ),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: -30,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.incomeA.withOpacity(0.08),
                  Colors.transparent,
                ],
                radius: 1.0,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.expenseA.withOpacity(0.06),
                  Colors.transparent,
                ],
                radius: 1.0,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 100,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentB.withOpacity(0.05),
                  Colors.transparent,
                ],
                radius: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static LinearGradient incomeGradient() {
    return const LinearGradient(
      colors: [AppColors.incomeA, AppColors.incomeB],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient expenseGradient() {
    return const LinearGradient(
      colors: [AppColors.expenseA, AppColors.expenseB],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient accentGradient() {
    return const LinearGradient(
      colors: [AppColors.accentA, AppColors.accentB],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color categoryGlow(String category) {
    return AppColors.getCategoryColor(category).withOpacity(0.25);
  }
}
