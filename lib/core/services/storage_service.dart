import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static Future<String> uploadProfileImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}