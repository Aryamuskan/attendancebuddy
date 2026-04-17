import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStudentService {
  static Future<void> addStudent({
    required String uid,
    required String name,
    required String email,
    required String batchId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // 1️⃣ Batch ke andar student list (ADMIN VIEW)
    await firestore
        .collection('batches')
        .doc(batchId)
        .collection('students')
        .doc(uid)
        .set({
      'uid': uid,
      'name': name,
      'email': email,
      'batch': batchId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ Student master profile (STUDENT SIDE)
    await firestore.collection('students').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'batch': batchId,
      'profileCompleted': false,
      'photoUrl': null,
    }, SetOptions(merge: true));
  }
}