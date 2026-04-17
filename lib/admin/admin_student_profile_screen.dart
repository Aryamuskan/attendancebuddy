import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStudentProfileScreen extends StatelessWidget {
  final String uid;
  const AdminStudentProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final d = snap.data!.data()!;
        return Scaffold(
          appBar: AppBar(title: Text(d['name'] ?? 'Student')),
          body: Column(
            children: [
              if (d['photoUrl'] != null)
                Image.network(d['photoUrl'], height: 120),
              Text('Class: ${d['class'] ?? ''}'),
              Text('College: ${d['college'] ?? ''}'),
            ],
          ),
        );
      },
    );
  }
}