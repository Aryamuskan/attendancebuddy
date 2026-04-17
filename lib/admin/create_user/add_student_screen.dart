import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/student_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String? selectedBatchId;
  bool loading = false;
  Future<void> createStudent() async {
    if (!_formKey.currentState!.validate() || selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await StudentService.createStudent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        batchId: selectedBatchId!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student added successfully")),
      );

      _nameController.clear();
      _emailController.clear();
      setState(() => selectedBatchId = null);
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
      appBar: AppBar(title: const Text("Add Student")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Student Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 16),

              /// 🔥 LIVE BATCH DROPDOWN
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('batches')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<String>(
                    decoration:
                    const InputDecoration(labelText: "Select Batch"),
                    value: selectedBatchId,
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedBatchId = value);
                    },
                    validator: (v) =>
                    v == null ? "Please select batch" : null,
                  );
                },
              ),

              const SizedBox(height: 30),

              loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: createStudent,
                  child: const Text("Add Student"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}