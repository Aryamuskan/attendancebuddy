import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PresentStudentsScreen extends StatelessWidget {
  const PresentStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Present Students"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance_records')
            .where('status', isEqualTo: 'present') // 🔥 only present
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students marked present"));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data =
              records[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(data['studentName'] ?? "No Name"),
                  subtitle: Text("ClassId: ${data['classId']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}