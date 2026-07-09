import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/team_provider.dart';
import '../../../providers/document_provider.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/document_model.dart';

class RequestChangeDialog extends ConsumerStatefulWidget {
  const RequestChangeDialog({super.key});

  @override
  ConsumerState<RequestChangeDialog> createState() => _RequestChangeDialogState();
}

class _RequestChangeDialogState extends ConsumerState<RequestChangeDialog> {
  ManagerListItem? _selectedManager;
  DocumentModel? _selectedDocument;
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final managersAsync = ref.watch(managersProvider);
    final documentsAsync = ref.watch(documentsProvider);
    final requestState = ref.watch(requestChangeProvider);

    ref.listen(requestChangeProvider, (previous, next) {
      if (next.successMessage != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
        ref.read(requestChangeProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return AlertDialog(
      backgroundColor: AppColors.cardBody,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Request change from manager", style: AppTextStyles.sectionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manager", style: AppTextStyles.inputLabel),
            const SizedBox(height: 6),
            managersAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text("Failed to load managers"),
              data: (managers) => DropdownButtonFormField<ManagerListItem>(
                value: _selectedManager,
                items: managers
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedManager = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text("Document (optional)", style: AppTextStyles.inputLabel),
            const SizedBox(height: 6),
            documentsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text("Failed to load documents"),
              data: (documents) => DropdownButtonFormField<DocumentModel>(
                value: _selectedDocument,
                items: documents
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.filename)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDocument = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text("Message", style: AppTextStyles.inputLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Describe the change you'd like made...",
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel", style: AppTextStyles.secondaryText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: requestState.isLoading || _selectedManager == null
              ? null
              : () => ref.read(requestChangeProvider.notifier).submit(
            managerId: _selectedManager!.id,
            documentId: _selectedDocument?.id,
            message: _messageController.text.trim(),
          ),
          child: requestState.isLoading
              ? const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text("Send request",
              style: AppTextStyles.buttonText.copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}