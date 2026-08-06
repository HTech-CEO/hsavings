import 'package:flutter/material.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174380), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF3F6F8),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174380), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF10141A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF10141A)),
        cardTheme: const CardThemeData(color: Color(0xFF1B1F28)),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
