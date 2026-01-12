import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guru_app/firebase_options.dart';
import 'package:guru_app/screens/login_screen.dart';
import 'package:shared/services/service_providers.dart';

import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:guru_app/screens/onboarding_screen.dart'; // Import OnboardingScreen
import 'package:guru_app/screens/guru_home_screen.dart'; // Import GuruHomeScreen
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async { // Changed main to Future<void> async
  WidgetsFlutterBinding.ensureInitialized(); // Required for async main
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app();
  }
  await Hive.initFlutter(); // Initialize Hive
  runApp(
    const ProviderScope( // Wrap with ProviderScope
      child: GuruApp(),
    ),
  );
}

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guru App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769E0)),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F1F3C),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE3E8EF)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: const Color(0xFF1769E0),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    return ref.watch(currentUserStreamProvider).when(
          data: (user) {
            if (authService.isFirstRun) {
              return const OnboardingScreen();
            }
            if (user != null) {
              return const GuruHomeScreen();
            } else {
              return LoginScreen();
            }
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Error: $error')),
          ),
        );
  }
}
