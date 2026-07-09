import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../router/route_names.dart';
import '../shared/responsive_wrapper.dart';
import 'widgets/velixra_logo_header.dart';
import 'widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleSignIn() async {
    final role = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (role == "owner") {
      context.go(RouteNames.ownerDashboard);
    } else if (role == "manager") {
      context.go(RouteNames.managerPanel);
    } else if (role == "employee") {
      context.go(RouteNames.chat);
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveWrapper(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                color: AppColors.cardBody,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VelixraLogoHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthTextField(
                            label: "Email ID",
                            controller: _emailController,
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: "Password",
                            controller: _passwordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // wired to forgot-password flow next
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Forgot password?",
                                style: AppTextStyles.linkGold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                              authState.isLoading ? null : _handleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                                  : Text("Sign in",
                                  style: AppTextStyles.buttonText),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              "OTP verification for password reset",
                              style: AppTextStyles.secondaryText,
                              textAlign: TextAlign.center,
                            ),

                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(RouteNames.acceptInvitation),
                              child: Text(
                                "Have an invitation code? Accept it here",
                                style: AppTextStyles.linkGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}