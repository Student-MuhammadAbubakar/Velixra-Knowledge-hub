import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/team_provider.dart';
import '../../router/route_names.dart';
import 'widgets/velixra_logo_header.dart';
import 'widgets/auth_text_field.dart';

class AcceptInvitationScreen extends ConsumerStatefulWidget {
  const AcceptInvitationScreen({super.key});

  @override
  ConsumerState<AcceptInvitationScreen> createState() =>
      _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState
    extends ConsumerState<AcceptInvitationScreen> {
  final _tokenController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final acceptState = ref.watch(acceptInvitationProvider);

    ref.listen(acceptInvitationProvider, (previous, next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Account created! Please sign in.")),
        );
        context.go(RouteNames.login);
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          Text(
                            "Accept your invitation",
                            style: AppTextStyles.sectionTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Paste the invitation code from your email, "
                                "then set up your account.",
                            style: AppTextStyles.secondaryText,
                          ),
                          const SizedBox(height: 20),
                          AuthTextField(
                            label: "Invitation code",
                            controller: _tokenController,
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: "Full name",
                            controller: _nameController,
                          ),
                          const SizedBox(height: 18),
                          AuthTextField(
                            label: "Create password",
                            controller: _passwordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: acceptState.isLoading
                                  ? null
                                  : () {
                                ref
                                    .read(acceptInvitationProvider
                                    .notifier)
                                    .accept(
                                  token: _tokenController.text
                                      .trim(),
                                  name: _nameController.text
                                      .trim(),
                                  password:
                                  _passwordController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: acceptState.isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                                  : Text("Create account",
                                  style: AppTextStyles.buttonText),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(RouteNames.login),
                              child: Text(
                                "Already have an account? Sign in",
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