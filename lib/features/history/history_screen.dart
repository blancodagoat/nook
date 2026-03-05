import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/constants/app_text_styles.dart';
import 'package:nook/data/models/transaction.dart';
import 'package:nook/features/add_transaction/add_transaction_sheet.dart';
import 'package:nook/features/dashboard/dashboard_provider.dart';
import 'package:nook/features/dashboard/widgets/transaction_list_item.dart';
import 'package:nook/shared/widgets/ambient_background.dart';
import 'package:nook/shared/widgets/empty_state_widget.dart';
import 'package:nook/shared/widgets/nook_chip.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactionsAsync = ref.watch(filteredTransactionsProvider);
    final filterType = ref.watch(filterTypeProvider);

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
                    title: Text('History', style: AppTextStyles.title),
                    centerTitle: true,
                    background: Container(color: Colors.transparent),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    searchController: _searchController,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    filterType: filterType,
                    onFilterChanged: (type) {
                      ref.read(filterTypeProvider.notifier).state = type;
                    },
                  ),
                ),
                filteredTransactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return SliverFillRemaining(
                        child: EmptyStateWidget(
                          title: 'No transactions found',
                          subtitle: filterType != null || _searchController.text.isNotEmpty
                              ? 'Try adjusting your filters'
                              : 'Add your first transaction from the home screen',
                        ),
                      );
                    }

                    final groupedTransactions = _groupByMonth(transactions);

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = groupedTransactions.entries.elementAt(index);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MonthSectionHeader(
                                month: entry.key,
                                transactions: entry.value,
                              ),
                              ...entry.value.asMap().entries.map((e) {
                                final transaction = e.value;
                                return TransactionListItem(
                                  transaction: transaction,
                                  index: e.key,
                                  showDate: true,
                                  onDelete: () async {
                                    await ref.read(transactionNotifierProvider.notifier)
                                        .deleteTransaction(transaction.id!);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Transaction deleted'),
                                          backgroundColor: AppColors.surface1,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            side: const BorderSide(color: AppColors.frostBorder),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  onTap: () => showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => AddTransactionSheet(transaction: transaction),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                        childCount: groupedTransactions.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (error, _) => const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error loading transactions',
                        style: TextStyle(color: AppColors.negative),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupByMonth(List<Transaction> transactions) {
    final grouped = <DateTime, List<Transaction>>{};

    for (final transaction in transactions) {
      final date = transaction.date;
      final key = DateTime(date.year, date.month);

      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    return grouped;
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {

  _SearchBarDelegate({
    required this.searchController,
    required this.onChanged,
    required this.filterType,
    required this.onFilterChanged,
  });
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final String? filterType;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.bg.withValues(alpha: 0.96),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: CupertinoTextField(
              controller: searchController,
              onChanged: onChanged,
              placeholder: 'Search transactions...',
              placeholderStyle: const TextStyle(color: AppColors.textTertiary),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Icon(CupertinoIcons.search, color: AppColors.textTertiary, size: 18),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: null,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                NookChip(
                  label: 'All',
                  color: AppColors.accent,
                  isSelected: filterType == null,
                  onTap: () => onFilterChanged(null),
                ),
                const SizedBox(width: 6),
                NookChip(
                  label: 'Income',
                  color: AppColors.positive,
                  isSelected: filterType == 'income',
                  onTap: () => onFilterChanged('income'),
                ),
                const SizedBox(width: 6),
                NookChip(
                  label: 'Expenses',
                  color: AppColors.negative,
                  isSelected: filterType == 'expense',
                  onTap: () => onFilterChanged('expense'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 120;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return filterType != oldDelegate.filterType;
  }
}

class _MonthSectionHeader extends StatelessWidget {

  const _MonthSectionHeader({
    required this.month,
    required this.transactions,
  });
  final DateTime month;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    final net = income - expense;
    final formatter = NumberFormat.compactCurrency(symbol: 'HUF ');

    return Container(
      color: AppColors.bg.withValues(alpha: 0.96),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            DateFormat('MMMM yyyy').format(month).toUpperCase(),
            style: AppTextStyles.sectionLabel,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: net >= 0 ? AppColors.positiveSoft : AppColors.negativeSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${net >= 0 ? '+' : ''}${formatter.format(net)}",
              style: AppTextStyles.mono.copyWith(
                color: net >= 0 ? AppColors.positive : AppColors.negative,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
