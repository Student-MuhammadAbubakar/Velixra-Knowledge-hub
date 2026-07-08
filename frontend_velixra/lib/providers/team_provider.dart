import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../data/datasource/team_datasource.dart';
import '../data/repository/team_repository.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TeamRepository(TeamDatasource(dio));
});

class InviteState {
  final bool isLoading;
  final String? successMessage;
  final String? error;
  InviteState({this.isLoading = false, this.successMessage, this.error});
}

class InviteNotifier extends StateNotifier<InviteState> {
  final TeamRepository repository;
  InviteNotifier(this.repository) : super(InviteState());

  Future<void> inviteManager(String email) async {
    state = InviteState(isLoading: true);
    try {
      final message = await repository.inviteManager(email);
      state = InviteState(successMessage: message);
    } catch (e) {
      state = InviteState(error: e.toString());
    }
  }

  Future<void> inviteEmployee(String email) async {
    state = InviteState(isLoading: true);
    try {
      final message = await repository.inviteEmployee(email);
      state = InviteState(successMessage: message);
    } catch (e) {
      state = InviteState(error: e.toString());
    }
  }

  void reset() => state = InviteState();
}

final inviteProvider = StateNotifierProvider<InviteNotifier, InviteState>((ref) {
  return InviteNotifier(ref.watch(teamRepositoryProvider));
});