import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassLocationManagerScreen extends StatefulWidget {
  const ClassLocationManagerScreen({super.key});

  @override
  State<ClassLocationManagerScreen> createState() =>
      _ClassLocationManagerScreenState();
}

class _ClassLocationManagerScreenState
    extends State<ClassLocationManagerScreen> {
  final nameCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final radiusCtrl = TextEditingController();

  final ref =
  FirebaseFirestore.instance.collection('class_locations');

  Future<void> addLocation() async {
    if (nameCtrl.text.isEmpty ||
        latCtrl.text.isEmpty ||
        lngCtrl.text.isEmpty ||
        radiusCtrl.text.isEmpty) return;

    await ref.add({
      'className': nameCtrl.text.trim(),
      'lat': double.parse(latCtrl.text),
      'lng': double.parse(lngCtrl.text),
      'radius': double.parse(radiusCtrl.text),
      'createdAt': FieldValue.serverTimestamp(),
    });

    nameCtrl.clear();
    latCtrl.clear();
    lngCtrl.clear();
    radiusCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Location Manager"),
        centerTitle: true,
      ),
      body: Column(
        children: [

          // ADD FORM
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration:
                  const InputDecoration(labelText: "Class / Room Name"),
                ),
                TextField(
                  controller: latCtrl,
                  decoration:
                  const InputDecoration(labelText: "Latitude"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: lngCtrl,
                  decoration:
                  const InputDecoration(labelText: "Longitude"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: radiusCtrl,
                  decoration:
                  const InputDecoration(labelText: "Radius (meters)"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addLocation,
                  child: const Text("Save Location"),
                )
              ],
            ),
          ),

          const Divider(),

          // LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snap.data!.docs.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(d['className']),
                      subtitle: Text(
                          "Lat: ${d['lat']} | Lng: ${d['lng']} | Radius: ${d['radius']}m"),
                      onLongPress: () => doc.reference.delete(),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}