/// FILE: lib/screens/wrapper.dart
/// Wrapper widget that listens to auth state changes
/// Redirects to appropriate screen based on login status
/// Based on the Widget Tree from Firebase slides

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for auth state changes using Provider
    final authProvider = context.watch<AuthProvider>();

    // If user is logged in, show Home screen
    // If not logged in, show Welcome screen (which leads to Login/Signup)
    if (authProvider.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const WelcomeScreen();
    }
  }
}
