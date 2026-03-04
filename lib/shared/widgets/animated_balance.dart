import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_text_styles.dart';

class AnimatedBalance extends StatefulWidget {
  final double amount;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  const AnimatedBalance({
    super.key,
    required this.amount,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutExpo,
  });

  @override
  State<AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<AnimatedBalance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _previousAmount = widget.amount;
    _animateTo(widget.amount);
  }

  @override
  void didUpdateWidget(AnimatedBalance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousAmount = oldWidget.amount;
      _animateTo(widget.amount);
    }
  }

  void _animateTo(double target) {
    _animation = Tween<double>(
      begin: _previousAmount,
      end: target,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
        return Text(
          formatter.format(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}
