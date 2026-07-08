import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/chat_model.dart';

/// Renders one message — navy bubble aligned right for the user,
/// white bubble aligned left for the assistant, matching the design.
class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final String? sourceLabel; // e.g. "Finance_Policy_2026.pdf · p.4"

  const ChatBubble({super.key, required this.message, this.sourceLabel});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.navy : AppColors.inputFill,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: isUser
                  ? AppTextStyles.bodyText.copyWith(color: AppColors.white)
                  : AppTextStyles.bodyText,
            ),
            if (!isUser && sourceLabel != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 14, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      sourceLabel!,
                      style: AppTextStyles.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}