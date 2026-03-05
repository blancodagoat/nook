import 'package:flutter/material.dart';
import 'package:nook/core/constants/app_colors.dart';

class GradientText extends StatelessWidget {

  const GradientText({
    required this.text, required this.style, required this.gradient, super.key,
  });

  const GradientText.income({
    required this.text, required this.style, super.key,
  }) : gradient = const LinearGradient(
          colors: [AppColors.incomeA, AppColors.incomeB],
        );

  const GradientText.expense({
    required this.text, required this.style, super.key,
  }) : gradient = const LinearGradient(
          colors: [AppColors.expenseA, AppColors.expenseB],
        );
  final String text;
  final TextStyle style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: gradient.createShader,
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
