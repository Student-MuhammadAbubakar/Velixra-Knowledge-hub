/// Mirrors your backend's AskQuestionResponse, ChatMessageResponse,
/// and ChatSessionResponse schemas.

class ChatMessageModel {
  final int id;
  final String role; // "user" | "assistant"
  final String content;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json["id"],
      role: json["role"],
      content: json["content"],
      createdAt: json["created_at"],
    );
  }
}

class ChatSessionModel {
  final int id;
  final String? title;
  final String createdAt;
  final List<ChatMessageModel> messages;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json["id"],
      title: json["title"],
      createdAt: json["created_at"],
      messages: (json["messages"] as List? ?? [])
          .map((m) => ChatMessageModel.fromJson(m))
          .toList(),
    );
  }
}

class AskQuestionResult {
  final String answer;
  final int sessionId;
  final List<int> sourceDocumentIds;

  AskQuestionResult({
    required this.answer,
    required this.sessionId,
    required this.sourceDocumentIds,
  });

  factory AskQuestionResult.fromJson(Map<String, dynamic> json) {
    return AskQuestionResult(
      answer: json["answer"],
      sessionId: json["session_id"],
      sourceDocumentIds: List<int>.from(json["source_document_ids"]),
    );
  }
}