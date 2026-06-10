import 'package:flutter/material.dart';
import "contatos_screen.dart";

void main() {
  runApp(const ContatosApp());
}

class ContatosApp extends StatelessWidget {
  const ContatosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ContatosScreen(),
    );
  }
}
