import 'package:go_router/go_router.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/accept_invitation_screen.dart';
import '../presentation/owner/owner_dashboard_screen.dart';
import '../presentation/manager/manager_panel_screen.dart';
import '../presentation/chat/chat_screen.dart';
import 'route_names.dart';

/// Builds the router with a specific starting location, decided at
/// app launch based on whether a valid session already exists.
GoRouter buildAppRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: RouteNames.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: RouteNames.acceptInvitation, builder: (context, state) => const AcceptInvitationScreen()),
      GoRoute(path: RouteNames.ownerDashboard, builder: (context, state) => const OwnerDashboardScreen()),
      GoRoute(path: RouteNames.managerPanel, builder: (context, state) => const ManagerPanelScreen()),
      GoRoute(path: RouteNames.chat, builder: (context, state) => const ChatScreen()),
    ],
  );
}