import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("User not found in Firestore");
    }

    return doc['role'];
  }
}