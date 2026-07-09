import '../datasource/team_datasource.dart';
import '../models/team_model.dart';

class TeamRepository {
  final TeamDatasource datasource;
  TeamRepository(this.datasource);

  Future<String> inviteManager(String email) => datasource.inviteManager(email);
  Future<String> inviteEmployee(String email) => datasource.inviteEmployee(email);


// ... inside TeamRepository class ...

  Future<List<ManagerListItem>> getManagers() => datasource.getManagers();

  Future<String> requestChange({required int managerId, int? documentId, required String message}) {
    return datasource.requestChange(managerId: managerId, documentId: documentId, message: message);
  }
  Future<void> acceptInvitation({
    required String token,
    required String name,
    required String password,
  }) {
    return datasource.acceptInvitation(token: token, name: name, password: password);
  }
}