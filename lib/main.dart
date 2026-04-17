import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';

import 'core/theme/app_theme_builder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  // 🔥 Change role here (admin / teacher / student)
  UserRole currentRole = UserRole.student;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppThemeBuilder.build(
        role: currentRole,
        isDark: false,
      ),
      darkTheme: AppThemeBuilder.build(
        role: currentRole,
        isDark: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Stack(
        children: [
          const AuthGate(),

          // 🔥 Floating Theme Toggle Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: toggleTheme,
              child: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}