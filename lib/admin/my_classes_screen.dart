import 'package:flutter/material.dart';

class MyClassesScreen extends StatelessWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Classes")),
      body: const Center(
        child: Text(
          "Admin ke banaye hue classes yahan dikhenge",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}