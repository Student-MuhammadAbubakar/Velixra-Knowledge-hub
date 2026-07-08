// router/app_router.dart
import 'package:go_router/go_router.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/owner/owner_dashboard_screen.dart';
import '../presentation/manager/manager_panel_screen.dart';
import '../presentation/chat/chat_screen.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  routes: [
    GoRoute(path: RouteNames.login, builder: (context, state) => const LoginScreen()),
    GoRoute(path: RouteNames.ownerDashboard, builder: (context, state) => const OwnerDashboardScreen()),
    GoRoute(path: RouteNames.managerPanel, builder: (context, state) => const ManagerPanelScreen()),
    GoRoute(path: RouteNames.chat, builder: (context, state) => const ChatScreen()),
  ],
);