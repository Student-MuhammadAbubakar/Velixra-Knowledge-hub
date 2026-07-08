import '../datasource/team_datasource.dart';

class TeamRepository {
  final TeamDatasource datasource;
  TeamRepository(this.datasource);

  Future<String> inviteManager(String email) => datasource.inviteManager(email);
  Future<String> inviteEmployee(String email) => datasource.inviteEmployee(email);
}