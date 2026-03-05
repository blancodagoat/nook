import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nook/core/constants/app_colors.dart';
import 'package:nook/core/constants/app_text_styles.dart';

class EmojiPicker extends StatefulWidget {

  const EmojiPicker({
    required this.onEmojiSelected, super.key,
    this.selectedEmoji,
  });
  final String? selectedEmoji;
  final void Function(String) onEmojiSelected;

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  static const List<String> _commonEmojis = [
    '💰', '💵', '💳', '🏦', '💎', '💼',
    '🍔', '🍕', '🍜', '🍳', '🥗', '🍰',
    '🚗', '🚕', '🚌', '✈️', '🚂', '⛽',
    '🛍️', '👗', '👟', '💄', '🎁', '📦',
    '🏠', '🏨', '🏢', '🏗️', '🏭', '🏫',
    '💊', '🏥', '🩺', '💉', '🧬', '🔬',
    '🎬', '🎵', '🎮', '🎯', '🎨', '🎭',
    '📚', '✏️', '🎓', '💡', '📊', '🔍',
    '💻', '📱', '⌨️', '🖥️', '🖱️', '💾',
    '🌈', '☀️', '🌙', '⭐', '🔥', '💧',
    '🌱', '🌲', '🌸', '🌺', '🍀', '🌴',
    '🐕', '🐱', '🐭', '🐹', '🐰', '🦊',
    '❤️', '🧡', '💛', '💚', '💙', '💜',
    '🎁', '🎈', '🎉', '🎊', '🎄', '🎃',
    '📷', '📹', '🎥', '📺', '📻', '🔦',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Choose an Emoji',
              style: AppTextStyles.sectionLabel,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _commonEmojis.length,
              itemBuilder: (context, index) {
                final emoji = _commonEmojis[index];
                final isSelected = emoji == widget.selectedEmoji;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onEmojiSelected(emoji);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.accent, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
