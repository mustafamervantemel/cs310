/// FILE: lib/screens/onboarding3_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({super.key});

  void _finish(BuildContext context) {
    AuthService.completeOnboarding();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              const Text(
                'DISCOVER TAs\nAND BEST NOTES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _finish(context),
                  child: const Text('Start Using SuNote'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
