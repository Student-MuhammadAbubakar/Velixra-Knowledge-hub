import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../data/datasource/document_datasource.dart';
import '../data/repository/document_repository.dart';
import '../data/models/document_model.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DocumentRepository(DocumentDatasource(dio));
});

final documentsProvider =
FutureProvider.autoDispose<List<DocumentModel>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocuments();
});

/// Handles upload/delete actions and lets the UI know when to refresh
/// the document list afterward.
class DocumentActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final DocumentRepository repository;
  final Ref ref;

  DocumentActionsNotifier(this.repository, this.ref)
      : super(const AsyncData(null));

  Future<void> upload({
    required String filePath,
    required String fileName,
    required String visibility,
  }) async {
    state = const AsyncLoading();
    try {
      await repository.uploadDocument(
        filePath: filePath,
        fileName: fileName,
        visibility: visibility,
      );
      state = const AsyncData(null);
      ref.invalidate(documentsProvider); // triggers list to refetch
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> delete(int documentId) async {
    state = const AsyncLoading();
    try {
      await repository.deleteDocument(documentId);
      state = const AsyncData(null);
      ref.invalidate(documentsProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final documentActionsProvider =
StateNotifierProvider<DocumentActionsNotifier, AsyncValue<void>>((ref) {
  return DocumentActionsNotifier(ref.watch(documentRepositoryProvider), ref);
});