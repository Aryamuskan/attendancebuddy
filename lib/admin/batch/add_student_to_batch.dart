import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddStudentToBatchScreen extends StatefulWidget {
  final String batchId;
  final String batchName;

  const AddStudentToBatchScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<AddStudentToBatchScreen> createState() =>
      _AddStudentToBatchScreenState();
}

class _AddStudentToBatchScreenState
    extends State<AddStudentToBatchScreen> {

  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String selectedGender = "Male";
  bool loading = false;

  Future<void> addStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    FirebaseApp? secondaryApp;

    try {
      /// 1️⃣ Secondary Firebase App (SAFE like teacher)
      secondaryApp = await Firebase.initializeApp(
        name: "SecondaryStudent",
        options: Firebase.app().options,
      );

      final secondaryAuth =
      FirebaseAuth.instanceFor(app: secondaryApp);

      const tempPassword = "Temp@123456";

      /// 2️⃣ Create Auth User
      UserCredential cred =
      await secondaryAuth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim().toLowerCase(),
        password: tempPassword,
      );

      final uid = cred.user!.uid;

      /// 3️⃣ Save in users collection (GLOBAL PROFILE)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        "uid": uid,
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim().toLowerCase(),
        "gender": selectedGender,
        "role": "student",
        "batchId": widget.batchId,
        "createdAt": FieldValue.serverTimestamp(),
      });

      /// 4️⃣ Save in students collection (ROLE DATA)
      await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .set({
        "uid": uid,
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim().toLowerCase(),
        "gender": selectedGender,
        "batchId": widget.batchId,
        "status": "active",
        "createdAt": FieldValue.serverTimestamp(),
      });

      /// 5️⃣ Save inside batch subcollection (MEMBERSHIP)
      await FirebaseFirestore.instance
          .collection('batches')
          .doc(widget.batchId)
          .collection('students')
          .doc(uid)
          .set({
        "uid": uid,
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim().toLowerCase(),
        "gender": selectedGender,
        "joinedAt": FieldValue.serverTimestamp(),
      });

      /// 6️⃣ Update batch count
      await FirebaseFirestore.instance
          .collection('batches')
          .doc(widget.batchId)
          .update({
        'studentCount': FieldValue.increment(1),
      });

      /// 7️⃣ Send password reset email
      await secondaryAuth.sendPasswordResetEmail(
        email: emailCtrl.text.trim().toLowerCase(),
      );

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Student created & password setup email sent"),
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      String message = "Error occurred";

      if (e.code == 'email-already-in-use') {
        message = "Email already exists!";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

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
      appBar: AppBar(
        title: Text("Add Student • ${widget.batchName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              TextFormField(
                controller: nameCtrl,
                decoration:
                const InputDecoration(labelText: "Student Name"),
                validator: (v) =>
                v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: emailCtrl,
                decoration:
                const InputDecoration(labelText: "Email"),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Required";
                  }
                  if (!v.contains("@")) {
                    return "Invalid Email";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedGender,
                items: const [
                  DropdownMenuItem(
                      value: "Male", child: Text("Male")),
                  DropdownMenuItem(
                      value: "Female", child: Text("Female")),
                  DropdownMenuItem(
                      value: "Other", child: Text("Other")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                decoration:
                const InputDecoration(labelText: "Gender"),
              ),

              const SizedBox(height: 20),

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: addStudent,
                child: const Text("Add Student"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}