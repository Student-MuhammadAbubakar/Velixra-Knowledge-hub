import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/role_label.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/question_progress_tile.dart';
import 'widgets/logout_button.dart';
import 'widgets/invite_dialog.dart';
import 'widgets/request_change_dialog.dart';
import '../../providers/team_provider.dart';
import '../shared/responsive_wrapper.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(ownerAnalyticsProvider);
    final documentsAsync = ref.watch(documentsProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveWrapper(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                color: AppColors.cardBody,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Navy header
                    // Navy header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 24),
                      decoration: const BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: currentUserAsync.when(
                        loading: () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Loading...", style: AppTextStyles.headerTitle),
                            const LogoutButton(),
                          ],
                        ),
                        error: (_, __) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Owner", style: AppTextStyles.headerTitle),
                            const LogoutButton(),
                          ],
                        ),
                        data: (user) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: AppTextStyles.headerTitle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const LogoutButton(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(roleLabel(user.role), style: AppTextStyles.headerSubtitle),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: analyticsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text("Failed to load analytics: $err"),
                        ),
                        data: (analytics) {
                          final maxCount = analytics.topQuestions.isEmpty
                              ? 0
                              : analytics.topQuestions
                              .map((q) => q.timesAsked)
                              .reduce((a, b) => a > b ? a : b);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stat cards row
                              Row(
                                children: [
                                  StatCard(
                                    label: "Documents",
                                    value: analytics.documentStats
                                        .totalDocuments
                                        .toString(),
                                  ),
                                  const SizedBox(width: 12),
                                  StatCard(
                                    label: "Queries today",
                                    value: analytics.topQuestions
                                        .fold<int>(
                                        0, (sum, q) => sum + q.timesAsked)
                                        .toString(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Top asked questions card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBody,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Top asked questions",
                                        style: AppTextStyles.sectionTitle),
                                    const SizedBox(height: 12),
                                    ...analytics.topQuestions
                                        .take(5)
                                        .map((q) => QuestionProgressTile(
                                      question: q.questionCluster,
                                      count: q.timesAsked,
                                      maxCount: maxCount,
                                    )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Public documents card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBody,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Public documents",
                                        style: AppTextStyles.sectionTitle),
                                    const SizedBox(height: 12),
                                    documentsAsync.when(
                                      loading: () => const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: LinearProgressIndicator(),
                                      ),
                                      error: (err, _) =>
                                          Text("Failed to load documents"),
                                      data: (docs) {
                                        final publicDocs = docs
                                            .where((d) => d.visibility == "public")
                                            .toList();

                                        if (publicDocs.isEmpty) {
                                          return Text(
                                            "No public documents yet.",
                                            style: AppTextStyles.secondaryText,
                                          );
                                        }

                                        return Column(
                                          children: publicDocs
                                              .map((doc) => Padding(
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 6),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.circle,
                                                  size: 8,
                                                  color: AppColors
                                                      .statusGreen,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        doc.filename,
                                                        style:
                                                        AppTextStyles
                                                            .bodyText,
                                                      ),
                                                      if (doc
                                                          .uploadedByName !=
                                                          null)
                                                        Text(
                                                          "Uploaded by ${doc.uploadedByName}",
                                                          style: AppTextStyles
                                                              .secondaryText,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                              .toList(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Request change from manager button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const RequestChangeDialog(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    "Request change from manager",
                                    style: AppTextStyles.buttonText
                                        .copyWith(color: AppColors.textPrimary),
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
                                        title: "Invite a manager",
                                        onSubmit: (email) => ref
                                            .read(inviteProvider.notifier)
                                            .inviteManager(email),
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
                                    "Invite manager",
                                    style: AppTextStyles.buttonText
                                        .copyWith(color: AppColors.navy),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}