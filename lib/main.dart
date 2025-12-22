/// FILE: lib/main.dart
/// Main entry point with Firebase initialization and MultiProvider setup

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';

// Services
import 'services/firestore_service.dart';

// Utils
import 'utils/app_colors.dart';

// Screens
import 'screens/wrapper.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_results_screen.dart';
import 'screens/upload_note_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/purchased_notes_screen.dart';
import 'screens/uploaded_notes_screen.dart';
import 'screens/note_detail_screen.dart';
import 'screens/ta_profile_screen.dart';
import 'screens/edit_note_screen.dart';
import 'models/note_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SuNoteApp());
}

class SuNoteApp extends StatelessWidget {
  const SuNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (non-ChangeNotifier)
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        // State Providers (ChangeNotifier)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SuNote',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: AppColors.navy,
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(backgroundColor: AppColors.navy, foregroundColor: Colors.white, elevation: 0),
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: Brightness.light),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.navy,
              scaffoldBackgroundColor: AppColors.darkBackground,
              appBarTheme: AppBarTheme(backgroundColor: Colors.grey[900], foregroundColor: Colors.white, elevation: 0),
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy, brightness: Brightness.dark),
            ),
            home: const Wrapper(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/onboarding1': (context) => const OnboardingScreen(),
              '/home': (context) => const HomeScreen(),
              '/searchResults': (context) => const SearchResultsScreen(),
              '/uploadNote': (context) => const UploadNoteScreen(),
              '/profile': (context) => const UserProfileScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/purchasedNotes': (context) => const PurchasedNotesScreen(),
              '/uploadedNotes': (context) => const UploadedNotesScreen(),
              '/noteDetail': (context) => const NoteDetailScreen(),
              '/taProfile': (context) => const TaProfileScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/editNote') {
                final note = settings.arguments as NoteModel;
                return MaterialPageRoute(builder: (context) => EditNoteScreen(note: note));
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
