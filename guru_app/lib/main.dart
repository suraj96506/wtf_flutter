import 'package:flutter/material.dart';

void main() {
  runApp(const GuruApp());
}

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guru App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Guru App'),
        ),
        body: const Center(
          child: Text('Welcome to Guru App!'),
        ),
      ),
    );
  }
}
