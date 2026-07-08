import '../datasource/chat_datasource.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final ChatDatasource datasource;
  ChatRepository(this.datasource);

  Future<AskQuestionResult> askQuestion({
    required String question,
    int? sessionId,
  }) {
    return datasource.askQuestion(question: question, sessionId: sessionId);
  }

  Future<List<ChatSessionModel>> getSessions() => datasource.getSessions();

  Future<ChatSessionModel> getSessionDetail(int sessionId) =>
      datasource.getSessionDetail(sessionId);
}