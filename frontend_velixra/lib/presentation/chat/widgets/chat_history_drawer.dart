import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/chat_provider.dart';
import '../../../data/repository/chat_repository.dart';

/// Slide-out drawer listing past chat sessions. Tapping one loads its
/// full message history into the active chat; "New chat" clears the
/// current conversation so a new session starts on the next message.
class ChatHistoryDrawer extends ConsumerWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(chatSessionsProvider);
    final chatRepository = ref.watch(chatRepositoryProvider);

    return Drawer(
      backgroundColor: AppColors.cardBody,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text("Chat history",
                        style: AppTextStyles.sectionTitle),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(chatProvider.notifier).startNewChat();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.add, color: AppColors.textPrimary),
                  label: Text(
                    "New chat",
                    style: AppTextStyles.buttonText
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Expanded(
              child: sessionsAsync.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("Failed to load history: $err"),
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No past conversations yet.",
                        style: AppTextStyles.secondaryText,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline,
                            size: 20),
                        title: Text(
                          session.title ?? "Untitled chat",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyText,
                        ),
                        onTap: () async {
                          final fullSession =
                          await chatRepository.getSessionDetail(session.id);
                          ref.read(chatProvider.notifier).loadSession(fullSession);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}