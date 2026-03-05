import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/constants/app_text_styles.dart';
import 'package:nook/core/constants/category_meta.dart';
import 'package:nook/data/models/transaction.dart';
import 'package:nook/features/dashboard/dashboard_provider.dart';
import 'package:nook/shared/widgets/ambient_background.dart';
import 'package:nook/shared/widgets/empty_state_widget.dart';
import 'package:nook/shared/widgets/month_selector.dart';
import 'package:nook/shared/widgets/nook_card.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider);
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
                  pinned: true,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text('Summary', style: AppTextStyles.title),
                    centerTitle: true,
                    background: Container(color: Colors.transparent),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        MonthSelector(),
                        Gap(24),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: statsAsync.when(
                    data: (stats) {
                      if (stats.totalIncome == 0 && stats.totalExpense == 0) {
                        return const EmptyStateWidget(
                          title: 'No data for this month',
                          subtitle: 'Add some transactions to see your summary',
                          icon: Icons.pie_chart_outline_rounded,
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNetSummaryBanner(stats),
                            const Gap(20),
                            _buildDonutChart(stats, categoryTotalsAsync),
                            const Gap(24),
                            _buildDailyBarChart(stats),
                            const Gap(28),
                            Text(
                              'CATEGORY BREAKDOWN',
                              style: AppTextStyles.sectionLabel,
                            ),
                            const Gap(16),
                            _buildCategoryBreakdown(stats, categoryTotalsAsync),
                            const Gap(120),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                    error: (_, __) => const Center(
                      child: Text('Error loading summary'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetSummaryBanner(DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: NookCard(
            tint: AppColors.positive,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.positive,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Text('Income', style: AppTextStyles.caption),
                  ],
                ),
                const Gap(8),
                Text(
                  NumberFormat.currency(symbol: 'HUF ').format(stats.totalIncome),
                  style: AppTextStyles.cardAmount,
                ),
              ],
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: NookCard(
            tint: AppColors.negative,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.negative,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Text('Spent', style: AppTextStyles.caption),
                  ],
                ),
                const Gap(8),
                Text(
                  NumberFormat.currency(symbol: 'HUF ').format(stats.totalExpense),
                  style: AppTextStyles.cardAmount,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart(DashboardStats stats, AsyncValue<Map<String, double>> categoryTotalsAsync) {
    return categoryTotalsAsync.when(
      data: (categoryTotals) {
        final expenseCategories = categoryTotals.entries
            .where((e) => !CategoryData.incomeCategories.contains(e.key))
            .toList();

        if (expenseCategories.isEmpty) {
          return const NookCard(
            padding: EdgeInsets.all(20),
            radius: 24,
            child: SizedBox(
              height: 180,
              child: Center(
                child: Text('No expenses this month', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          );
        }

        final total = expenseCategories.fold<double>(0, (sum, e) => sum + e.value);

        return NookCard(
          padding: const EdgeInsets.all(24),
          radius: 28,
          child: SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 80,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: expenseCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final meta = CategoryData.getMeta(item.key);
                      final isTouched = index == touchedIndex;

                      return PieChartSectionData(
                        value: item.value,
                        color: meta.color,
                        radius: isTouched ? 28 : 22,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SPENT', style: AppTextStyles.sectionLabel),
                    const Gap(4),
                    Text(
                      NumberFormat.compactCurrency(symbol: 'HUF ').format(total),
                      style: AppTextStyles.cardAmount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
      },
      loading: () => const NookCard(
        padding: EdgeInsets.all(24),
        radius: 28,
        child: SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
        ),
      ),
      error: (_, __) => const NookCard(
        padding: EdgeInsets.all(24),
        radius: 28,
        child: SizedBox(
          height: 220,
          child: Center(child: Text('Error loading chart')),
        ),
      ),
    );
  }

  Widget _buildDailyBarChart(DashboardStats stats) {
    return NookCard(
      padding: const EdgeInsets.all(20),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Spending', style: AppTextStyles.caption),
          const Gap(16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index + 1,
                    barRods: [
                      BarChartRodData(
                        toY: (stats.totalExpense / 7) * (0.5 + (index % 3) * 0.3),
                        width: 6,
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.5)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.frostBorder,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) => Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][(val.toInt() - 1) % 7],
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),
              duration: 600.ms,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(DashboardStats stats, AsyncValue<Map<String, double>> categoryTotalsAsync) {
    return categoryTotalsAsync.when(
      data: (categoryTotals) {
        final expenseCategories = categoryTotals.entries
            .where((e) => !CategoryData.incomeCategories.contains(e.key))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (expenseCategories.isEmpty) {
          return const SizedBox.shrink();
        }

        final total = expenseCategories.fold<double>(0, (sum, e) => sum + e.value);

        return Column(
          children: expenseCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final meta = CategoryData.getMeta(item.key);
            final percentage = item.value / total * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NookCard(
                tint: meta.color,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(meta.emoji, style: const TextStyle(fontSize: 18))),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.key, style: AppTextStyles.txTitle),
                              ),
                              Text(
                                NumberFormat.currency(symbol: 'HUF ').format(item.value),
                                style: AppTextStyles.txAmount,
                              ),
                            ],
                          ),
                          const Gap(8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: AppColors.surface3,
                              valueColor: AlwaysStoppedAnimation(meta.color),
                              minHeight: 3,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            '${percentage.toStringAsFixed(1)}% of total',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 80 * index))
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
