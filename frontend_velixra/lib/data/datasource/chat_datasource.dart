import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../models/chat_model.dart';

class ChatDatasource {
  final Dio dio;
  ChatDatasource(this.dio);

  Future<AskQuestionResult> askQuestion({
    required String question,
    int? sessionId,
  }) async {
    try {
      final response = await dio.post(ApiConstants.chatAsk, data: {
        "question": question,
        "session_id": sessionId,
      });
      return AskQuestionResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<ChatSessionModel>> getSessions() async {
    try {
      final response = await dio.get(ApiConstants.chatSessions);
      return (response.data as List)
          .map((s) => ChatSessionModel.fromJson(s))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ChatSessionModel> getSessionDetail(int sessionId) async {
    try {
      final response =
      await dio.get("${ApiConstants.chatSessions}/$sessionId");
      return ChatSessionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}