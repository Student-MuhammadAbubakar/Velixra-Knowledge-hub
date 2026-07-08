import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// One row in "Top asked questions" — label, count, and a gold progress bar
/// showing relative frequency against the top question's count.
class QuestionProgressTile extends StatelessWidget {
  final String question;
  final int count;
  final int maxCount; // used to scale the bar proportionally

  const QuestionProgressTile({
    super.key,
    required this.question,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxCount == 0 ? 0.0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(question, style: AppTextStyles.bodyText),
              ),
              Text("$count", style: AppTextStyles.secondaryText),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}