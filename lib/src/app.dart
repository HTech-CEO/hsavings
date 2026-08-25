import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class HSavingsApp extends StatelessWidget {
  const HSavingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HSavings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF174380),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6F8),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF174380),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF10141A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF10141A)),
        cardTheme: const CardThemeData(color: Color(0xFF1B1F28)),
      ),
      themeMode: ThemeMode.system,
      home: const _AuthGate(),
    );
  }
}

/// Displays only authenticated application content.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return session == null ? const AuthScreen() : const HomeScreen();
      },
    );
  }
}
