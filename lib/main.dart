import 'package:flutter/material.dart';

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
          bodyMedium: TextStyle(
            color: Color(0xFF596579),
          ),
        ),
      ),
      home: const StarterScreen(),
    );
  }
}

class StarterScreen extends StatelessWidget {
  const StarterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algorithmic Dungeon'),
        backgroundColor: const Color(0xFF3867D6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_tree_outlined,
                size: 72,
                color: Color(0xFF3867D6),
              ),
              const SizedBox(height: 16),
              Text(
                'Algorithmic Dungeon',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Escape the Labyrinth • DAA Academic Project',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFDCE3ED)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Phase 0 Foundation Active\nReady for Phase 1: Domain Models & Dijkstra Engine',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF172033),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
