import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'forgot_password_screen.dart';
import 'package:attendancebuddy/student/student_invite_check_screen.dart';
import 'package:attendancebuddy/student/screens/student_dashboard.dart';
import 'package:attendancebuddy/admin/admin_dashboard.dart';
import 'package:attendancebuddy/teacher/teacher_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> login() async {
    if (emailCtrl.text.trim().isEmpty ||
        passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email & password required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 🔐 FIREBASE AUTH LOGIN
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailCtrl.text.trim().toLowerCase(),
        password: passwordCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // 🔎 CHECK USERS COLLECTION
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        throw "No profile found. Contact admin.";
      }

      final role = userDoc['role'] ?? '';

      if (role == 'admin') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
        return;
      }
      else if (role == 'teacher') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherDashboard()),
        );
        return;
      }
      else if (role == 'student') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
        return;
      }
      else {
        throw "Invalid role assigned";
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF7E22CE)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.png', height: 90),
                    const SizedBox(height: 20),

                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordCtrl,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      child: const Text("New student? Set Password"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const StudentInviteCheckScreen(),
                          ),
                        );
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text("Forgot Password?"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ForgotPasswordScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        child: loading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text("Login"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}