import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The bottom input row — rounded gray text field, gold circular send button.
class ChatInputBar extends StatefulWidget {
  final Future<void> Function(String) onSend;
  final bool isSending;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isSending,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _handleSend(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Ask something...",
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: widget.isSending
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
                  : const Icon(Icons.arrow_forward,
                  color: AppColors.textPrimary),
              onPressed: _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}