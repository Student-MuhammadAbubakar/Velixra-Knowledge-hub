import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../data/datasource/team_datasource.dart';
import '../data/repository/team_repository.dart';
import '../data/models/team_model.dart';


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

// ... existing InviteState, InviteNotifier, inviteProvider stay unchanged ...
class AcceptInvitationState {
  final bool isLoading;
  final bool success;
  final String? error;
  AcceptInvitationState({this.isLoading = false, this.success = false, this.error});
}

class AcceptInvitationNotifier extends StateNotifier<AcceptInvitationState> {
  final TeamRepository repository;
  AcceptInvitationNotifier(this.repository) : super(AcceptInvitationState());

  Future<void> accept({
    required String token,
    required String name,
    required String password,
  }) async {
    state = AcceptInvitationState(isLoading: true);
    try {
      await repository.acceptInvitation(token: token, name: name, password: password);
      state = AcceptInvitationState(success: true);
    } catch (e) {
      state = AcceptInvitationState(error: e.toString());
    }
  }
}
final managersProvider = FutureProvider.autoDispose<List<ManagerListItem>>((ref) async {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.getManagers();
});

class RequestChangeState {
  final bool isLoading;
  final String? successMessage;
  final String? error;
  RequestChangeState({this.isLoading = false, this.successMessage, this.error});
}

class RequestChangeNotifier extends StateNotifier<RequestChangeState> {
  final TeamRepository repository;
  RequestChangeNotifier(this.repository) : super(RequestChangeState());

  Future<void> submit({required int managerId, int? documentId, required String message}) async {
    state = RequestChangeState(isLoading: true);
    try {
      final result = await repository.requestChange(
        managerId: managerId,
        documentId: documentId,
        message: message,
      );
      state = RequestChangeState(successMessage: result);
    } catch (e) {
      state = RequestChangeState(error: e.toString());
    }
  }

  void reset() => state = RequestChangeState();
}

final requestChangeProvider =
StateNotifierProvider<RequestChangeNotifier, RequestChangeState>((ref) {
  return RequestChangeNotifier(ref.watch(teamRepositoryProvider));
});
final acceptInvitationProvider =
StateNotifierProvider<AcceptInvitationNotifier, AcceptInvitationState>((ref) {
  return AcceptInvitationNotifier(ref.watch(teamRepositoryProvider));
});