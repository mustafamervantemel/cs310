/// FILE: lib/main.dart
import 'package:flutter/material.dart';

import 'utils/app_colors.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding1_screen.dart';
import 'screens/onboarding2_screen.dart';
import 'screens/onboarding3_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_results_screen.dart';
import 'screens/upload_note_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/purchased_notes_screen.dart';
import 'screens/uploaded_notes_screen.dart';
import 'screens/note_detail_screen.dart';
import 'screens/ta_profile_screen.dart';

void main() {
  runApp(const SuNoteApp());
}

class SuNoteApp extends StatelessWidget {
  const SuNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuNote',
      debugShowCheckedModeBanner: false,

      // Uygulama açıldığında ilk karşımıza Welcome geliyor.
      initialRoute: '/welcome',

      theme: ThemeData(
        primaryColor: AppColors.navy,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      routes: {
        // Auth
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),

        // Onboarding
        '/onboarding1': (context) => const Onboarding1Screen(),
        '/onboarding2': (context) => const Onboarding2Screen(),
        '/onboarding3': (context) => const Onboarding3Screen(),

        // Main screens
        '/home': (context) => HomeScreen(),
        '/searchResults': (context) => const SearchResultsScreen(),
        '/uploadNote': (context) => const UploadNoteScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/purchasedNotes': (context) => const PurchasedNotesScreen(),
        '/uploadedNotes': (context) => const UploadedNotesScreen(),
        '/noteDetail': (context) => const NoteDetailScreen(),
        '/taProfile': (context) => const TaProfileScreen(),

        // Optional welcome
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}
