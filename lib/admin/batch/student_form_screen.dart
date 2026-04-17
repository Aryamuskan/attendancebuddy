import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFormScreen extends StatefulWidget {
  final String batchId;
  final String batchName;

  const StudentFormScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  bool loading = false;

  Future<void> inviteStudent() async {
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields required")),
      );
      return;
    }

    setState(() => loading = true);
    final email = emailCtrl.text.trim().toLowerCase();

    try {
      await FirebaseFirestore.instance
          .collection('student_invites')
          .doc(email)
          .set({
        'name': nameCtrl.text.trim(),
        'email': email,
        'batchId': widget.batchId,
        'batchName': widget.batchName,
        'invitedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
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
      appBar: AppBar(
        title: Text("Add Student • ${widget.batchName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Student Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 30),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: inviteStudent,
              child: const Text("Invite Student"),
            ),
          ],
        ),
      ),
    );
  }
}