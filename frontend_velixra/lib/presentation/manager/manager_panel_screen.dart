import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/document_provider.dart';
import 'widgets/document_list_tile.dart';
import '../owner/widgets/logout_button.dart';
import '../owner/widgets/invite_dialog.dart';
import '../../providers/team_provider.dart';

class ManagerPanelScreen extends ConsumerWidget {
  const ManagerPanelScreen({super.key});

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "docx", "txt"],
    );
    if (result == null || result.files.single.path == null) return;

    final file = result.files.single;
    await ref.read(documentActionsProvider.notifier).upload(
      filePath: file.path!,
      fileName: file.name,
      visibility: "public",
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsProvider);
    final actionsState = ref.watch(documentActionsProvider);

    ref.listen(documentActionsProvider, (previous, next) {
      next.whenOrNull(
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Action failed: $err")),
        ),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              color: AppColors.cardBody,
              child: Column(
                children: [
                  // Navy header with gold square icon (top right, per design)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Acme Corp", style: AppTextStyles.headerSubtitle),
                            const SizedBox(height: 4),
                            Text("Manager panel", style: AppTextStyles.headerTitle),
                          ],
                        ),
                        Row(
                          children: [
                            const LogoutButton(),
                            const SizedBox(width: 8),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Upload button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: actionsState.isLoading
                                  ? null
                                  : () => _handleUpload(context, ref),
                              icon: actionsState.isLoading
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textPrimary,
                                ),
                              )
                                  : const Icon(Icons.upload,
                                  color: AppColors.textPrimary),
                              label: Text(
                                "Upload document",
                                style: AppTextStyles.buttonText
                                    .copyWith(color: AppColors.textPrimary),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => InviteDialog(
                                    title: "Invite an employee",
                                    onSubmit: (email) =>
                                        ref.read(inviteProvider.notifier).inviteEmployee(email),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.navy),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Invite employee",
                                style: AppTextStyles.buttonText.copyWith(color: AppColors.navy),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text("Active documents",
                              style: AppTextStyles.sectionTitle),
                          const SizedBox(height: 14),

                          documentsAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                  child: CircularProgressIndicator()),
                            ),
                            error: (err, _) =>
                                Text("Failed to load documents: $err"),
                            data: (documents) {
                              if (documents.isEmpty) {
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "No documents uploaded yet.",
                                    style: AppTextStyles.secondaryText,
                                  ),
                                );
                              }
                              return Column(
                                children: documents
                                    .map((doc) => DocumentListTile(
                                  document: doc,
                                  onEdit: () {
                                    // toggle visibility flow, wired next
                                  },
                                  onDelete: () async {
                                    await ref
                                        .read(documentActionsProvider
                                        .notifier)
                                        .delete(doc.id);
                                  },
                                ))
                                    .toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                          documentsAsync.maybeWhen(
                            data: (documents) => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text("This week",
                                      style: AppTextStyles.sectionTitle),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${documents.length} uploads",
                                    style: AppTextStyles.secondaryText,
                                  ),
                                ],
                              ),
                            ),
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}