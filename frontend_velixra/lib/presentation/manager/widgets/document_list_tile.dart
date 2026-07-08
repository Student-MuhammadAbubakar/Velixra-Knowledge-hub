import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/document_model.dart';

/// One row in the Manager Panel's "Active documents" list —
/// filename, status subtitle, and edit/delete icon buttons.
class DocumentListTile extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentListTile({
    super.key,
    required this.document,
    required this.onEdit,
    required this.onDelete,
  });

  String get _statusLabel {
    switch (document.processStatus) {
      case "ready":
        return "Indexed";
      case "processing":
        return "Processing...";
      case "pending":
        return "Pending...";
      case "failed":
        return "Failed";
      default:
        return document.processStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = document.processStatus == "ready";

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.filename, style: AppTextStyles.bodyText),
                const SizedBox(height: 2),
                Text(_statusLabel, style: AppTextStyles.secondaryText),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: isReady ? AppColors.textPrimary : AppColors.divider,
            onPressed: isReady ? onEdit : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: isReady ? AppColors.textPrimary : AppColors.divider,
            onPressed: isReady ? onDelete : null,
          ),
        ],
      ),
    );
  }
}