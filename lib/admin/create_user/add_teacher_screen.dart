import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  String selectedGender = "Male";

  bool loading = false;

  Future<void> createTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    FirebaseApp? secondaryApp;

    try {
      // 1️⃣ Secondary Firebase App (admin safe)
      secondaryApp = await Firebase.initializeApp(
        name: "Secondary",
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      const tempPassword = "Temp@12345";

      // 2️⃣ Auth user create
      UserCredential cred =
      await secondaryAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: tempPassword,
      );

      final uid = cred.user!.uid;

      // 3️⃣ Firestore profile (users)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "gender": selectedGender,
        "subject": _subjectController.text.trim(),
        "role": "teacher",
        "status": "active",
        "createdAt": FieldValue.serverTimestamp(),
      });

// 3️⃣.5 🔥 NEW: teachers collection (IMPORTANT)
      await FirebaseFirestore.instance.collection('teachers').doc(uid).set({
        "uid": uid,
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "subject": _subjectController.text.trim(),
        "status": "active",
        "role": "teacher",
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 4️⃣ Reset password mail
      await secondaryAuth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Teacher created & reset email sent"),
        ),
      );

      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Teacher")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Teacher Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Enter email" : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(labelText: "Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                onChanged: (val) => setState(() => selectedGender = val!),
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: "Subject"),
                validator: (v) => v!.isEmpty ? "Enter subject" : null,
              ),
              const SizedBox(height: 30),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: createTeacher,
                  child: const Text("Create Teacher"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}