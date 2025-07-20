import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Illustration (placeholder)
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: AppColors.dominantPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(90),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 100,
                  color: AppColors.dominantPurple,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'UTME PrepMaster',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.dominantPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your smart study companion for UTME success!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to sign up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dominantPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create an account'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Navigate to sign in
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dominantPurple,
                    side: const BorderSide(color: AppColors.dominantPurple),
                  ),
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
