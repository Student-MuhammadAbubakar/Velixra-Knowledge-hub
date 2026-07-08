import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../router/route_names.dart';

/// Icon button placed in a dashboard header — clears the stored token
/// and returns to the login screen.
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
      onPressed: () async {
        await ref.read(authRepositoryProvider).logout();
        if (context.mounted) {
          context.go(RouteNames.login);
        }
      },
    );
  }
}