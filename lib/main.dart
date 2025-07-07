import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/game_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon do Dia',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.redAccent),
      home: const GameScreen(),
    );
  }
}
