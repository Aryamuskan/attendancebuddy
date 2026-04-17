import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  static Future<void> createStudent({
    required String name,
    required String email,
    required String batchId,
  }) async {
    final auth = FirebaseAuth.instance;
    const tempPassword = "Temp@123456";

    // 1️⃣ AUTH USER
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: tempPassword,
    );

    final uid = cred.user!.uid;

    // 2️⃣ FIRESTORE USER
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
      "role": "student",
      "batchId": batchId,
      "profileCompleted": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // 3️⃣ UPDATE BATCH COUNT
    await FirebaseFirestore.instance
        .collection('batches')
        .doc(batchId)
        .update({
      "studentCount": FieldValue.increment(1),
    });

    // 4️⃣ RESET PASSWORD MAIL
    await auth.sendPasswordResetEmail(email: email);
  }
}