import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/dashboard/dashboard_provider.dart';
import 'glass_card.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    
    return GlassCard(
      borderRadius: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(selectedMonthProvider.notifier).state = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
              );
            },
            child: Icon(
              Icons.chevron_left,
              color: AppColors.text50,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showMonthPicker(context, ref),
            child: Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: AppTextStyles.monthSelector,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              final now = DateTime.now();
              final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
              if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
                ref.read(selectedMonthProvider.notifier).state = nextMonth;
              }
            },
            child: Icon(
              Icons.chevron_right,
              color: AppColors.text50,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.read(selectedMonthProvider);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.surface0,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border(
            top: BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.label.copyWith(color: AppColors.text50),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Select Month',
                    style: AppTextStyles.txTitle,
                  ),
                  CupertinoButton(
                    child: Text(
                      'Done',
                      style: AppTextStyles.label.copyWith(color: AppColors.accentA),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.monthYear,
                initialDateTime: selectedMonth,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (date) {
                  ref.read(selectedMonthProvider.notifier).state = date;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
