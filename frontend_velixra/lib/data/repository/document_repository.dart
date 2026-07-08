import '../datasource/document_datasource.dart';
import '../models/document_model.dart';

class DocumentRepository {
  final DocumentDatasource datasource;
  DocumentRepository(this.datasource);

  Future<List<DocumentModel>> getDocuments() => datasource.getDocuments();

  Future<DocumentModel> uploadDocument({
    required String filePath,
    required String fileName,
    required String visibility,
  }) {
    return datasource.uploadDocument(
      filePath: filePath,
      fileName: fileName,
      visibility: visibility,
    );
  }

  Future<void> deleteDocument(int documentId) =>
      datasource.deleteDocument(documentId);
}