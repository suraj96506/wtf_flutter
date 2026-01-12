import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/service_providers.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:trainer_app/firebase_options.dart';
import 'package:trainer_app/screens/trainer_home_screen.dart'; // Import TrainerHomeScreen
import 'package:trainer_app/screens/login_screen.dart'; // Import LoginScreen

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized(); // Required for async main
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    Firebase.app();
  }
  await Hive.initFlutter();
  runApp(
    const ProviderScope(
      child: TrainerApp(),
    ),
  );
}

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trainer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE50914)),
        scaffoldBackgroundColor: const Color(0xFFFDF7F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2A0909),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE50914),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
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
              // Trainer has no onboarding; treat as login screen.
              return LoginScreen();
            }
            if (user != null) {
              return const TrainerHomeScreen();
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
