import 'package:flutter/material.dart';
import '../login/login_screen.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Role")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roleButton(context, "Admin"),
            const SizedBox(height: 20),
            _roleButton(context, "Teacher"),
            const SizedBox(height: 20),
            _roleButton(context, "Student"),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context, String role) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        },
        child: Text(role, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}