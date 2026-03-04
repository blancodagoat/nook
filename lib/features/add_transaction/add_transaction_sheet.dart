import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/category_meta.dart';
import '../../data/models/transaction.dart';
import '../dashboard/dashboard_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionSheet({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet>
    with SingleTickerProviderStateMixin {
  late bool _isExpense;
  late TextEditingController _amountController;
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _showNote = false;

  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _isExpense = t?.type == 'expense';
    _amountController = TextEditingController(
      text: t != null ? t.amount.toStringAsFixed(2) : '',
    );
    _titleController = TextEditingController(text: t?.title ?? '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _selectedCategory = t?.category ?? CategoryData.expenseCategories.first;
    _selectedDate = t?.date ?? DateTime.now();

    if (t != null && t.type == 'income') {
      _selectedCategory = t.category;
    }

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    return _isExpense ? CategoryData.expenseCategories : CategoryData.incomeCategories;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppColors.frostBorder, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildTypeToggle(),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text("Amount", style: AppTextStyles.sectionLabel),
                  const SizedBox(height: 8),
                  _AmountDisplay(
                    amount: _amountController.text,
                    isExpense: _isExpense,
                    controller: _amountController,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTitleField(),
            ),
            const SizedBox(height: 16),
            if (_showNote) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildNoteField(),
              ),
              const SizedBox(height: 16),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildNoteToggle(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSaveButton(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: 200.ms,
            curve: Curves.easeOutCubic,
            left: _isExpense ? 0 : MediaQuery.of(context).size.width / 2 - 20,
            top: 3,
            bottom: 3,
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: Container(
              decoration: BoxDecoration(
                color: _isExpense
                    ? AppColors.negative.withOpacity(0.15)
                    : AppColors.positive.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isExpense
                      ? AppColors.negative.withOpacity(0.4)
                      : AppColors.positive.withOpacity(0.4),
                  width: 0.75,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpense = true;
                      _selectedCategory = CategoryData.expenseCategories.first;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Expense',
                      style: AppTextStyles.txTitle.copyWith(
                        color: _isExpense ? AppColors.negative : AppColors.textSecondary,
                        fontWeight: _isExpense ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpense = false;
                      _selectedCategory = CategoryData.incomeCategories.first;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Income',
                      style: AppTextStyles.txTitle.copyWith(
                        color: !_isExpense ? AppColors.positive : AppColors.textSecondary,
                        fontWeight: !_isExpense ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final meta = CategoryData.getMeta(category);
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              Haptics.vibrate(HapticsType.light);
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? meta.color.withOpacity(0.15) : AppColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? meta.color.withOpacity(0.5) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(meta.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.split(' ').first,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          )
              .animate(target: isSelected ? 1 : 0)
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.02, 1.02))
              .then()
              .scale(end: const Offset(1.0, 1.0));
        },
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoTextField(
        controller: _titleController,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        placeholder: 'What was this for?',
        placeholderStyle: TextStyle(color: AppColors.textTertiary),
        decoration: null,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildNoteToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showNote = !_showNote;
        });
      },
      child: Row(
        children: [
          Icon(
            _showNote ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _showNote ? 'Remove note' : 'Add note (optional)',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoTextField(
        controller: _noteController,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        placeholder: 'Add a note...',
        placeholderStyle: TextStyle(color: AppColors.textTertiary),
        decoration: null,
        maxLines: 3,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTapDown: (_) {
        Haptics.vibrate(HapticsType.heavy);
        _slideController.forward();
      },
      onTapUp: (_) {
        _slideController.reverse();
        _save();
      },
      onTapCancel: () => _slideController.reverse(),
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_slideController.value * 0.03),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: _isExpense ? AppColors.negative : AppColors.positive,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_isExpense ? AppColors.negative : AppColors.positive).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _isExpense ? 'Add Expense' : 'Add Income',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _save() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a title');
      return;
    }

    final transaction = Transaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      type: _isExpense ? 'expense' : 'income',
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    if (widget.transaction != null) {
      await ref.read(transactionNotifierProvider.notifier).updateTransaction(transaction);
    } else {
      await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _AmountDisplay extends StatelessWidget {
  final String amount;
  final bool isExpense;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _AmountDisplay({
    required this.amount,
    required this.isExpense,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isExpense ? AppColors.negative : AppColors.positive).withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$',
            style: AppTextStyles.cardAmount.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 36,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: isExpense ? AppColors.negative : AppColors.positive,
                letterSpacing: -1,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
