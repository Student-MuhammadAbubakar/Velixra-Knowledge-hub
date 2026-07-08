import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/team_provider.dart';

/// Shared dialog used both for "Invite Manager" (owner) and
/// "Invite Employee" (manager) — only the title and the action differ.
class InviteDialog extends ConsumerStatefulWidget {
  final String title;
  final Future<void> Function(String email) onSubmit;

  const InviteDialog({super.key, required this.title, required this.onSubmit});

  @override
  ConsumerState<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<InviteDialog> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final inviteState = ref.watch(inviteProvider);

    ref.listen(inviteProvider, (previous, next) {
      if (next.successMessage != null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
        ref.read(inviteProvider.notifier).reset();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return AlertDialog(
      backgroundColor: AppColors.cardBody,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title, style: AppTextStyles.sectionTitle),
      content: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: "Email address",
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: inviteState.isLoading
              ? null
              : () => widget.onSubmit(_emailController.text.trim()),
          child: inviteState.isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text("Send invite",
              style: AppTextStyles.buttonText
                  .copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}