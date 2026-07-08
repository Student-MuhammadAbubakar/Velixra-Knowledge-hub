import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: VelixraApp()));
}

class VelixraApp extends StatelessWidget {
  const VelixraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Velixra Knowledge Hub",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}