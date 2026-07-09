import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/chat_provider.dart';
import '../shared/responsive_wrapper.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_history_drawer.dart';
import '../owner/widgets/logout_button.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen(chatProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ChatHistoryDrawer(),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              color: AppColors.cardBody,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Builder(
                              builder: (innerContext) => IconButton(
                                icon: const Icon(Icons.menu, color: AppColors.white),
                                onPressed: () => Scaffold.of(innerContext).openDrawer(),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ask Velixra", style: AppTextStyles.headerTitle),
                                Text("Reimbursement policy chat",
                                    style: AppTextStyles.headerSubtitle),
                              ],
                            ),
                          ],
                        ),
                        const LogoutButton(),
                      ],
                    ),
                  ),

                  // Message list — now sits under a bounded-height Column
                  // (SafeArea gives finite height), so Expanded works correctly
                  // and ListView.builder handles its own scrolling internally.
                  Expanded(
                    child: chatState.messages.isEmpty
                        ? Center(
                      child: Text(
                        "Ask a question about your company documents",
                        style: AppTextStyles.secondaryText,
                        textAlign: TextAlign.center,
                      ),
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatState.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatState.messages[index];
                        return ChatBubble(message: message);
                      },
                    ),
                  ),

                  ChatInputBar(
                    isSending: chatState.isSending,
                    onSend: (text) =>
                        ref.read(chatProvider.notifier).sendMessage(text),
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