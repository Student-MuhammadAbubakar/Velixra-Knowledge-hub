import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/document_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../router/route_names.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
      onPressed: () async {
        await ref.read(authRepositoryProvider).logout();

        // Wipe every provider that might be holding the previous user's
        // data in memory. Without this, a new user logging in during the
        // same app session (no full app restart) would see stale data —
        // or worse, another person's private chat history — left over
        // from before, since these providers don't reset automatically.
        ref.invalidate(chatProvider);
        ref.invalidate(chatSessionsProvider);
        ref.invalidate(documentsProvider);
        ref.invalidate(ownerAnalyticsProvider);

        if (context.mounted) {
          context.go(RouteNames.login);
        }
      },
    );
  }
}