import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth/login/login_screen.dart';
import '../../student/screens/complete_profile_screen.dart';
import '../../student/screens/student_dashboard.dart';
import 'package:attendancebuddy/admin/admin_dashboard.dart';
import 'package:attendancebuddy/teacher/teacher_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // ⏳ Waiting for auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, snap) {

            // ⏳ Firestore loading
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ❌ No profile
            if (!snap.hasData || !snap.data!.exists) {
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            final data = snap.data!.data() as Map<String, dynamic>;
            final role = data['role'];
            final completed = data['profileCompleted'] == true;

            // 🔐 ADMIN
            if (role == 'admin') {
              return const AdminDashboard();
            }

            // 👨‍🏫 TEACHER (DIRECT DASHBOARD)
            if (role == 'teacher') {
              return const TeacherDashboard();
            }

            // 🎓 STUDENT
            if (role == 'student') {
              return const StudentDashboard();
            }

            // 🛑 Safety fallback
            return const Scaffold(
              body: Center(child: Text('Invalid user role')),
            );
          },
        );
      },
    );
  }
}