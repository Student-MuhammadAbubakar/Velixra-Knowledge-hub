import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/token_storage.dart';
import 'router/app_router.dart';
import 'router/route_names.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Before showing any UI, check whether a valid session already exists
  // on disk, so the app opens directly to the right screen instead of
  // always forcing a fresh login.
  final tokenStorage = TokenStorage();
  final token = await tokenStorage.getToken();
  final role = await tokenStorage.getRole();

  String startLocation = RouteNames.login;
  if (token != null && role != null) {
    switch (role) {
      case "owner":
        startLocation = RouteNames.ownerDashboard;
        break;
      case "manager":
        startLocation = RouteNames.managerPanel;
        break;
      case "employee":
        startLocation = RouteNames.chat;
        break;
    }
  }

  runApp(ProviderScope(child: VelixraApp(startLocation: startLocation)));
}

class VelixraApp extends StatelessWidget {
  final String startLocation;
  const VelixraApp({super.key, required this.startLocation});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Velixra Knowledge Hub",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: buildAppRouter(startLocation),
    );
  }
}