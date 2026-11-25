import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles/firebase_options.dart';
import 'package:proyecto_moviles/pages/home_page.dart';
import 'package:proyecto_moviles/pages/logins_google.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B998B),
      primary: const Color(0xFF0B3C49),
      secondary: const Color(0xFFF46036),
      tertiary: const Color(0xFF1B998B),
      surface: const Color(0xFFFFF8EE),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: cs,
        scaffoldBackgroundColor: cs.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: cs.secondary,
            padding: const EdgeInsets.all(16),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: cs.secondary,
          foregroundColor: Colors.white,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snap.hasData ? const HomePage() : const LoginsGoogle();
        },
      ),
    );
  }
}
