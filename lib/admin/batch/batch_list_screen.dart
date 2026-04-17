import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'batch_students_screen.dart';

class BatchListScreen extends StatelessWidget {
  const BatchListScreen({super.key});

  // ================= CREATE BATCH =================
  void _createBatch(BuildContext context) {
    final ctrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text("Create Batch"),
              content: TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: "Batch Name (eg S01)",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                    if (ctrl.text.trim().isEmpty) return;

                    setState(() => loading = true);

                    try {
                      await FirebaseFirestore.instance
                          .collection('batches')
                          .add({
                        'name': ctrl.text.trim(),
                        'studentCount': 0,
                        'isActive': true,
                        'createdAt':
                        FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(ctx);
                    } catch (e) {
                      setState(() => loading = false);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                            Text("Error: ${e.toString()}")),
                      );
                    }
                  },
                  child: loading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white),
                  )
                      : const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= DELETE BATCH =================
  Future<void> _deleteBatch(
      BuildContext context, String batchId, int count) async {
    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Batch not empty. Remove students first."),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('batches')
        .doc(batchId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Batch deleted")),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Batch List")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createBatch(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('batches')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No batches created"));
          }

          final batches = snap.data!.docs;

          return ListView.builder(
            itemCount: batches.length,
            itemBuilder: (_, i) {
              final b = batches[i];
              final data = b.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Unnamed';
              final count = data['studentCount'] ?? 0;

              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text("Students: $count"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddStudentToBatchScreen(
                          batchId: b.id,
                          batchName: name,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteBatch(context, b.id, count),
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