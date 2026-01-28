import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/app_icon2.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.active,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.timer,
                    size: 60,
                    color: AppColors.textPrimary,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'BlitzTap',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
