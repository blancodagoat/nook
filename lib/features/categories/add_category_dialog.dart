import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/constants/app_text_styles.dart';
import 'package:nook/shared/widgets/emoji_picker.dart';

class AddCategoryDialog extends StatefulWidget {

  const AddCategoryDialog({
    required this.type, required this.onCategoryAdded, super.key,
  });
  final String type;
  final void Function(String name, String emoji, String colorHex) onCategoryAdded;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '📦';
  Color _selectedColor = AppColors.accent;
  bool _showEmojiPicker = false;

  final List<Color> _colorOptions = [
    AppColors.accent,
    AppColors.positive,
    AppColors.negative,
    AppColors.warning,
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF06B6D4),
    const Color(0xFF14B8A6),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _showEmojiPicker ? 520 : 400,
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.frostBorder, width: 0),
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
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New ${widget.type == 'expense' ? 'Expense' : 'Income'} Category',
                    style: AppTextStyles.sectionLabel,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showEmojiPicker = !_showEmojiPicker;
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.frostBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change emoji',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_showEmojiPicker)
                    EmojiPicker(
                      selectedEmoji: _selectedEmoji,
                      onEmojiSelected: (emoji) {
                        setState(() {
                          _selectedEmoji = emoji;
                          _showEmojiPicker = false;
                        });
                      },
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Category name',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose a color',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                          HapticFeedback.selectionClick();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: AppColors.textPrimary, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surface2,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a category name'),
                                  backgroundColor: AppColors.negative,
                                ),
                              );
                              return;
                            }
                            widget.onCategoryAdded(
                              _nameController.text.trim(),
                              _selectedEmoji,
                              _colorToHex(_selectedColor),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Save',
                                style: AppTextStyles.button,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
