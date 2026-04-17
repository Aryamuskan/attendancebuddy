import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickDate,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('date', isEqualTo: dateStr)
            .snapshots(),
        builder: (context, attSnap) {
          if (attSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!attSnap.hasData || attSnap.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No attendance found for $dateStr",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          final records = attSnap.data!.docs;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.class_),
                  title: Text(data['className'] ?? "Class"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Student: ${data['studentName'] ?? ""}"),
                      Text("Teacher: ${data['teacherName'] ?? ""}"),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      data['status'] ?? "Present",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}