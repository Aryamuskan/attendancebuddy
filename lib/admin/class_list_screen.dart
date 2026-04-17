import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClassHistoryScreen extends StatelessWidget {
  const ClassHistoryScreen({super.key});

  Future<void> _deleteClass(
      BuildContext context, String docId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Class"),
        content: const Text(
            "Are you sure you want to delete this class boundary?"),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection("class_locations")
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Class deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class History & List"),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("class_locations")
            .orderBy("createdAt",
            descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child:
                CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off,
                      size: 50,
                      color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text(
                    "No Classes Generated Yet",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding:
            const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data =
              doc.data() as Map<String, dynamic>;

              final name =
                  data["name"] ?? "Unnamed";

              final polygon =
              (data["polygon"] ?? [])
              as List;

              final createdAt =
              data["createdAt"] != null
                  ? (data["createdAt"]
              as Timestamp)
                  .toDate()
                  : null;

              return Container(
                margin:
                const EdgeInsets.only(
                    bottom: 14),
                padding:
                const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius:
                  BorderRadius.circular(
                      16),
                  border: Border.all(
                      color:
                      Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style:
                            const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                              Icons.delete_outline),
                          onPressed: () =>
                              _deleteClass(
                                  context,
                                  doc.id),
                        )
                      ],
                    ),
                    const SizedBox(
                        height: 6),
                    Text(
                      "${polygon.length} Boundary Points",
                      style: TextStyle(
                          color:
                          Colors.grey[600]),
                    ),
                    if (createdAt != null)
                      Padding(
                        padding:
                        const EdgeInsets
                            .only(top: 4),
                        child: Text(
                          "Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)}",
                          style: TextStyle(
                              color: Colors
                                  .grey[500],
                              fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}