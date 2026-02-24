import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SetupProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SetupProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep - 1;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: isCompleted || isCurrent
                              ? AppColors.primaryGradient
                              : null,
                          color: isCompleted || isCurrent
                              ? null
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (index < totalSteps - 1) const SizedBox(width: 6),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            'Step $currentStep of $totalSteps',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
