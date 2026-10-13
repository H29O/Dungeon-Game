import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const AlgorithmicDungeonApp());
}

class AlgorithmicDungeonApp extends StatelessWidget {
  const AlgorithmicDungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algorithmic Dungeon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF3867D6),
          onPrimary: Colors.white,
          secondary: Color(0xFF138A72),
          onSecondary: Colors.white,
          error: Color(0xFFD9534F),
          onError: Colors.white,
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF172033),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Color(0xFF172033),
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: Color(0xFF596579)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
