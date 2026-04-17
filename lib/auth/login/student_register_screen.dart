import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;

  // STUDENT REGISTER (FINAL & CORRECT)

  Future<void> register() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Valid email & 6+ char password required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final email = emailCtrl.text.trim().toLowerCase();

      // 1️⃣ CHECK INVITE
      final inviteRef = FirebaseFirestore.instance
          .collection('student_invites')
          .doc(email);

      final inviteSnap = await inviteRef.get();

      if (!inviteSnap.exists) {
        throw Exception("No active invite found for this email");
      }

      // 2️⃣ CREATE AUTH USER
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: passCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // 3️⃣ STUDENTS COLLECTION (UID BASED)
      await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .set({
        'uid': uid,
        'name': inviteSnap['name'],
        'email': email,
        'batchId': inviteSnap['batchId'],
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4️⃣ USERS COLLECTION (LOGIN SOURCE)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'uid': uid,
        'name': inviteSnap['name'],
        'email': email,
        'role': 'student',
        'batchId': inviteSnap['batchId'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 5️⃣ DELETE INVITE
      await inviteRef.delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'email-already-in-use'
                ? "Account already exists. Please login."
                : e.message ?? "Registration failed",
          ),
        ),
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
      appBar: AppBar(title: const Text("Set Student Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Invited Email",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Create Password",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account"),
              ),
            )
          ],
        ),
      ),
    );
  }
}