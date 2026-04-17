import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class GenerateClassScreen extends StatefulWidget {
  const GenerateClassScreen({super.key});

  @override
  State<GenerateClassScreen> createState() =>
      _GenerateClassScreenState();
}

class _GenerateClassScreenState
    extends State<GenerateClassScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController classNameController =
  TextEditingController();

  final TextEditingController widthController =
  TextEditingController();

  final TextEditingController heightController =
  TextEditingController();

  final List<Map<String, TextEditingController>>
  coordinates = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _resetCoordinates();
  }

  void _resetCoordinates() {
    coordinates.clear();
    for (int i = 0; i < 4; i++) {
      coordinates.add({
        "lat": TextEditingController(),
        "lng": TextEditingController(),
      });
    }
  }

  // ================= AUTO RECTANGLE =================

  Future<void> _autoGenerateRectangle() async {

    if (widthController.text.isEmpty ||
        heightController.text.isEmpty) {
      _showSnack("Enter width & height");
      return;
    }

    double width = double.parse(widthController.text);
    double height = double.parse(heightController.text);

    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showSnack("Location service disabled");
      return;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    if (permission ==
        LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      _showSnack("Location permission denied");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text("Capturing Center Location"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 15),
            Text("Stand still...\nDo not move."),
          ],
        ),
      ),
    );

    List<double> latList = [];
    List<double> lngList = [];

    for (int i = 0; i < 8; i++) {
      Position p =
      await Geolocator.getCurrentPosition(
        desiredAccuracy:
        LocationAccuracy.high,
      );

      latList.add(p.latitude);
      lngList.add(p.longitude);

      await Future.delayed(
          const Duration(milliseconds: 800));
    }

    Navigator.pop(context);

    double avgLat =
        latList.reduce((a, b) => a + b) /
            latList.length;

    double avgLng =
        lngList.reduce((a, b) => a + b) /
            lngList.length;

    double latOffset =
        (height / 2) * 0.000009;

    double lngOffset =
        (width / 2) *
            (0.000009 /
                cos(avgLat * pi / 180));

    List<Map<String, double>>
    generatedPolygon = [
      {
        "lat": avgLat + latOffset,
        "lng": avgLng - lngOffset
      },
      {
        "lat": avgLat + latOffset,
        "lng": avgLng + lngOffset
      },
      {
        "lat": avgLat - latOffset,
        "lng": avgLng + lngOffset
      },
      {
        "lat": avgLat - latOffset,
        "lng": avgLng - lngOffset
      },
    ];

    for (var coord in coordinates) {
      coord["lat"]!.dispose();
      coord["lng"]!.dispose();
    }

    coordinates.clear();

    for (var p in generatedPolygon) {
      coordinates.add({
        "lat": TextEditingController(
            text: p["lat"].toString()),
        "lng": TextEditingController(
            text: p["lng"].toString()),
      });
    }

    setState(() {});

    _showSnack("Rectangle Generated ✅");
  }

  // ================= SAVE CLASS =================

  Future<void> _saveClass() async {

    if (!_formKey.currentState!.validate())
      return;

    List<Map<String, double>> polygon =
    [];

    try {
      for (var coord in coordinates) {
        final lat = double.parse(
            coord["lat"]!.text.trim());
        final lng = double.parse(
            coord["lng"]!.text.trim());

        polygon.add({
          "lat": lat,
          "lng": lng,
        });
      }
    } catch (e) {
      _showSnack("Invalid coordinates");
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance
          .collection("class_locations")
          .add({
        "name":
        classNameController.text.trim(),
        "polygon": polygon,
        "createdAt": Timestamp.now(),
      });

      _showSuccessDialog();
      _resetForm();
    } catch (e) {
      _showSnack("Failed to save class");
    }

    setState(() => loading = false);
  }

  void _resetForm() {
    classNameController.clear();
    widthController.clear();
    heightController.clear();

    for (var coord in coordinates) {
      coord["lat"]!.dispose();
      coord["lng"]!.dispose();
    }

    setState(() {
      _resetCoordinates();
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
        SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
        const Text("✅ Class Generated"),
        content: const Text(
            "Boundary saved successfully."),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Widget _coordinateCard(int index) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
            color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text("Corner ${index + 1}",
              style: const TextStyle(
                  fontWeight:
                  FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller:
                  coordinates[index]
                  ["lat"],
                  decoration:
                  const InputDecoration(
                      labelText:
                      "Latitude",
                      border:
                      OutlineInputBorder()),
                  validator: (v) =>
                  v == null ||
                      v.isEmpty
                      ? "Required"
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller:
                  coordinates[index]
                  ["lng"],
                  decoration:
                  const InputDecoration(
                      labelText:
                      "Longitude",
                      border:
                      OutlineInputBorder()),
                  validator: (v) =>
                  v == null ||
                      v.isEmpty
                      ? "Required"
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    classNameController.dispose();
    widthController.dispose();
    heightController.dispose();

    for (var coord in coordinates) {
      coord["lat"]!.dispose();
      coord["lng"]!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
          const Text("Generate Virtual Class")),
      body: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              const Text("Class Name"),
              const SizedBox(height: 6),

              TextFormField(
                controller:
                classNameController,
                decoration:
                const InputDecoration(
                    border:
                    OutlineInputBorder()),
                validator: (v) =>
                v == null ||
                    v.isEmpty
                    ? "Required"
                    : null,
              ),

              const SizedBox(height: 20),

              const Text(
                  "Auto Generate From Center"),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                      widthController,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Width (meters)",
                        border:
                        OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller:
                      heightController,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Height (meters)",
                        border:
                        OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed:
                _autoGenerateRectangle,
                icon: const Icon(
                    Icons.auto_fix_high),
                label: const Text(
                    "Auto Generate Rectangle"),
              ),

              const SizedBox(height: 25),

              ...List.generate(
                  coordinates.length,
                      (index) =>
                      _coordinateCard(
                          index)),

              const SizedBox(height: 30),

              loading
                  ? const Center(
                  child:
                  CircularProgressIndicator())
                  : ElevatedButton(
                onPressed:
                _saveClass,
                child: const Text(
                    "Save Class"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}