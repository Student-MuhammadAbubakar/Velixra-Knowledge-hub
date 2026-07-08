import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// The navy header with the gold logo square, "Velixra" title, and
/// "Knowledge Hub" subtitle — appears at the top of the login card.
class VelixraLogoHeader extends StatelessWidget {
  const VelixraLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Text("Velixra", style: AppTextStyles.logoTitle),
          const SizedBox(height: 2),
          Text("Knowledge Hub", style: AppTextStyles.logoSubtitle),
        ],
      ),
    );
  }
}