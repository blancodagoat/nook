import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/nook_card.dart';
import '../../../shared/widgets/animated_balance.dart';
import '../dashboard_provider.dart';
import '../../../data/models/transaction.dart';

class BalanceHeroCard extends ConsumerWidget {
  const BalanceHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) => _buildCard(context, stats),
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildErrorCard(),
    );
  }

  Widget _buildCard(BuildContext context, DashboardStats stats) {
    return NookCard(
      padding: const EdgeInsets.all(24),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Total Balance", style: AppTextStyles.sectionLabel),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Mar 2026",
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const Gap(8),
          AnimatedBalance(
            amount: stats.balance,
            style: AppTextStyles.heroBalance,
          ),
          const Gap(4),
          Row(
            children: [
              Icon(
                stats.balance >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: stats.balance >= 0 ? AppColors.positive : AppColors.negative,
              ),
              const Gap(4),
              Text(
                "12% vs last month",
                style: AppTextStyles.caption.copyWith(
                  color: stats.balance >= 0 ? AppColors.positive : AppColors.negative,
                ),
              ),
            ],
          ),
          const Gap(20),
          Container(height: 0.5, color: AppColors.frostBorder),
          const Gap(20),
          Row(
            children: [
              _BalanceStat(
                label: "Income",
                amount: stats.totalIncome,
                color: AppColors.positive,
                icon: Icons.arrow_downward_rounded,
              ),
              Container(width: 0.5, height: 44, color: AppColors.frostBorder),
              _BalanceStat(
                label: "Spent",
                amount: stats.totalExpense,
                color: AppColors.negative,
                icon: Icons.arrow_upward_rounded,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildLoadingCard() {
    return NookCard(
      padding: const EdgeInsets.all(24),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(16),
          Container(
            width: 200,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return NookCard(
      padding: const EdgeInsets.all(24),
      radius: 28,
      tint: AppColors.negative,
      child: const Center(
        child: Text(
          'Failed to load data',
          style: TextStyle(color: AppColors.negative),
        ),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const Gap(1),
                Text(
                  formatter.format(amount),
                  style: AppTextStyles.cardAmount.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
