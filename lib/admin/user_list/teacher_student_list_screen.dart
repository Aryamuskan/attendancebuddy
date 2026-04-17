import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherStudentListScreen extends StatelessWidget {
  final String role;
  const TeacherStudentListScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == "teacher" ? "Teachers" : "Students"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: role)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No ${role == "teacher" ? "Teachers" : "Students"} Found",
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: role == "teacher"
                        ? Colors.indigo
                        : Colors.green,
                    child: Icon(
                      role == "teacher"
                          ? Icons.school
                          : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(data['name'] ?? "No Name"),
                  subtitle: Text(data['email'] ?? "No Email"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}