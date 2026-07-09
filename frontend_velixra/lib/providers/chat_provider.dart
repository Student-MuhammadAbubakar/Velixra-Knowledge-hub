import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../data/datasource/chat_datasource.dart';
import '../data/repository/chat_repository.dart';
import '../data/models/chat_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRepository(ChatDatasource(dio));
});

/// Holds the currently active conversation: its session id (null until
/// the first message is sent) and the running list of messages shown
/// on screen, built optimistically as the user chats.
class ChatState {
  final int? sessionId;
  final List<ChatMessageModel> messages;
  final bool isSending;
  final String? error;

  ChatState({
    this.sessionId,
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    int? sessionId,
    List<ChatMessageModel>? messages,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository repository;
  final Ref ref;

  ChatNotifier(this.repository, this.ref) : super(ChatState());

  Future<void> sendMessage(String question) async {
    if (question.trim().isEmpty) return;

    // Show the user's message immediately, before the server responds,
    // so the chat feels instant rather than waiting on a network round-trip.
    final optimisticUserMessage = ChatMessageModel(
      id: -1,
      role: "user",
      content: question,
      createdAt: DateTime.now().toIso8601String(),
    );

    state = state.copyWith(
      messages: [...state.messages, optimisticUserMessage],
      isSending: true,
      error: null,
    );

    try {
      final result = await repository.askQuestion(
        question: question,
        sessionId: state.sessionId,
      );

      final assistantMessage = ChatMessageModel(
        id: -2,
        role: "assistant",
        content: result.answer,
        createdAt: DateTime.now().toIso8601String(),
      );

      state = state.copyWith(
        sessionId: result.sessionId,
        messages: [...state.messages, assistantMessage],
        isSending: false,
      );

      // A new session may have just been created (or an existing one
      // updated with a new message) — refresh the drawer's cached list
      // so it reflects this conversation without needing a manual reload.
      ref.invalidate(chatSessionsProvider);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  void loadSession(ChatSessionModel session) {
    state = ChatState(sessionId: session.id, messages: session.messages);
  }

  void startNewChat() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider), ref);
});

final chatSessionsProvider =
FutureProvider.autoDispose<List<ChatSessionModel>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getSessions();
});