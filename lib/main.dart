import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PontPontApp());
}

class PontPontApp extends StatelessWidget {
  const PontPontApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PontPont Handbag Boutique',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB45309),
          primary: const Color(0xFF1C1917),
          secondary: const Color(0xFFFBBF24),
          surface: const Color(0xFFFAF7F2),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
