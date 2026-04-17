import 'package:flutter/material.dart';

import 'add_teacher_screen.dart';

class CreateUserScreen extends StatelessWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create User"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionButton(
              context,
              title: "Add Teacher",
              icon: Icons.school,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTeacherScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(title),
        onPressed: onTap,
      ),
    );
  }
}