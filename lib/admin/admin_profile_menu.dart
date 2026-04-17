import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfileMenu extends StatelessWidget {
  const AdminProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Text("Profile"),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Text("Logout"),
        ),
      ],
    );
  }
}