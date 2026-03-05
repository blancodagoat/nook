import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../shared/widgets/ambient_background.dart';
import '../../shared/widgets/month_selector.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/nook_card.dart';
import '../add_transaction/add_transaction_sheet.dart';
import 'dashboard_provider.dart';
import 'widgets/balance_hero_card.dart';
import 'widgets/transaction_list_item.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  centerTitle: true,
                  title: const MonthSelector(),
                ),
                SliverToBoxAdapter(
                  child: statsAsync.when(
                    data: (stats) {
                      if (stats.recentTransactions.isEmpty) {
                        return const EmptyStateWidget(
                          title: 'No transactions yet',
                          subtitle: 'Tap the + button to add your first transaction',
                        );
                      }

                      return Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: BalanceHeroCard(),
                          ),
                          const SizedBox(height: 16),
                          _QuickStatsRow(stats: stats),
                          const SizedBox(height: 8),
                          _SpendingProgress(spent: stats.totalExpense, budget: 5000),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                            child: Row(
                              children: [
                                Text("RECENT TRANSACTIONS", style: AppTextStyles.sectionLabel),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => context.go('/history'),
                                  child: Text(
                                    "See all",
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...List.generate(
                            stats.recentTransactions.length,
                            (index) {
                              final transaction = stats.recentTransactions[index];
                              return TransactionListItem(
                                transaction: transaction,
                                index: index,
                                onDelete: () async {
                                  await ref.read(transactionNotifierProvider.notifier)
                                      .deleteTransaction(transaction.id!);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Transaction deleted'),
                                        backgroundColor: AppColors.surface1,
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: const BorderSide(color: AppColors.frostBorder),
                                        ),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: AppColors.accent,
                                          onPressed: () {
                                            ref.read(transactionNotifierProvider.notifier)
                                                .addTransaction(transaction);
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onTap: () => _showEditSheet(context, ref, transaction),
                              );
                            },
                          ),
                          const SizedBox(height: 120),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: AppColors.negative, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load transactions',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => ref.invalidate(dashboardStatsProvider),
                            child: NookCard(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              tint: AppColors.accent,
                              child: Text(
                                'Retry',
                                style: AppTextStyles.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 60),
        child: _AddButton(
          onPressed: () async {
            await Haptics.vibrate(HapticsType.heavy);
            if (context.mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddTransactionSheet(),
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(transaction: transaction),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final dynamic stats;

  const _QuickStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _MiniMetric(
              label: "Daily Avg",
              value: "\$85",
              icon: Icons.today_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniMetric(
              label: "Largest",
              value: "\$120",
              icon: Icons.bolt_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MiniMetric(
              label: "Savings",
              value: "23%",
              icon: Icons.savings_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return NookCard(
      padding: const EdgeInsets.all(16),
      radius: 16,
      backgroundColor: AppColors.surface2,
      hasBorder: false,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.txAmount),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpendingProgress extends StatelessWidget {
  final double spent;
  final double budget;

  const _SpendingProgress({required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final percentage = (spent / budget).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NookCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text("Monthly Spending", style: AppTextStyles.caption),
                const Spacer(),
                Text(
                  "${(percentage * 100).toStringAsFixed(0)}%",
                  style: AppTextStyles.mono.copyWith(
                    color: percentage > 0.85 ? AppColors.negative : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(height: 6, color: AppColors.surface3),
                  AnimatedContainer(
                    duration: 900.ms,
                    curve: Curves.easeOutExpo,
                    height: 6,
                    width: MediaQuery.of(context).size.width * percentage * 0.9,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: percentage > 0.85
                            ? [AppColors.warning, AppColors.negative]
                            : [AppColors.accent, AppColors.positive],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("\$${spent.toStringAsFixed(0)}", style: AppTextStyles.mono),
                const Spacer(),
                Text("of \$${budget.toStringAsFixed(0)}", style: AppTextStyles.mono),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.03),
            child: Container(
              width: 160,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text('Add', style: AppTextStyles.button),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
