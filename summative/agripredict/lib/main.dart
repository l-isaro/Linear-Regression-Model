import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AgritechApp());
}

class AgritechApp extends StatelessWidget {
  const AgritechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agritech',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
