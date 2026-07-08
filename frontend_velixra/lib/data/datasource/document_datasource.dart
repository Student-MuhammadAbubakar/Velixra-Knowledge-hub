import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../models/document_model.dart';

class DocumentDatasource {
  final Dio dio;
  DocumentDatasource(this.dio);

  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await dio.get(ApiConstants.documents);
      return (response.data as List)
          .map((d) => DocumentModel.fromJson(d))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DocumentModel> uploadDocument({
    required String filePath,
    required String fileName,
    required String visibility,
  }) async {
    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        "visibility": visibility,
      });
      final response = await dio.post(
        ApiConstants.uploadDocument,
        data: formData,
      );
      return DocumentModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteDocument(int documentId) async {
    try {
      await dio.delete("${ApiConstants.documents}/$documentId");
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}