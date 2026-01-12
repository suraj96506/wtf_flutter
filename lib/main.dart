import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/services/service_providers.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:trainer_app/screens/trainer_home_screen.dart'; // Import TrainerHomeScreen
import 'package:trainer_app/screens/login_screen.dart'; // Import LoginScreen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        primarySwatch: Colors.red,
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

