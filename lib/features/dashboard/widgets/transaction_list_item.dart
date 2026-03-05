import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:intl/intl.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/constants/app_text_styles.dart';
import 'package:nook/core/constants/category_meta.dart';
import 'package:nook/data/models/transaction.dart';
import 'package:nook/shared/widgets/nook_card.dart';

class TransactionListItem extends StatelessWidget {

  const TransactionListItem({
    required this.transaction, super.key,
    this.onTap,
    this.onDelete,
    this.showDate = false,
    this.index = 0,
  });
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDate;
  final int index;

  @override
  Widget build(BuildContext context) {
    final meta = CategoryData.getMeta(transaction.category);
    final isIncome = transaction.type == 'income';
    final categoryColor = AppColors.getCategoryColor(transaction.category);
    final formatter = NumberFormat.currency(symbol: 'HUF ', decimalDigits: 2);
    final timeFormatter = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        key: ValueKey(transaction.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.18,
          children: [
            CustomSlidableAction(
              onPressed: (context) async {
                if (onDelete != null) {
                  await Haptics.vibrate(HapticsType.heavy);
                  onDelete!();
                }
              },
              backgroundColor: AppColors.negative.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.negative, size: 20),
            ),
          ],
        ),
        child: NookCard(
          tint: categoryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hasBorder: false,
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(meta.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.title, style: AppTextStyles.txTitle),
                      const Gap(2),
                      Text(
                        "${meta.label} · ${DateFormat('d MMM').format(transaction.date)}",
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}",
                      style: AppTextStyles.txAmount.copyWith(
                        color: isIncome ? AppColors.positive : AppColors.textPrimary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      timeFormatter.format(transaction.date),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: (index * 40).ms)
          .fadeIn(duration: 250.ms)
          .slideY(begin: 0.06, end: 0, duration: 250.ms, curve: Curves.easeOut),
    );
  }
}

class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
