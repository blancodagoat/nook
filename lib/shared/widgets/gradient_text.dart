import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/gradient_utils.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
  });

  const GradientText.income({
    super.key,
    required this.text,
    required this.style,
  }) : gradient = const LinearGradient(
          colors: [AppColors.incomeA, AppColors.incomeB],
        );

  const GradientText.expense({
    super.key,
    required this.text,
    required this.style,
  }) : gradient = const LinearGradient(
          colors: [AppColors.expenseA, AppColors.expenseB],
        );

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
