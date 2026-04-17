import 'package:flutter/material.dart';

import 'today_attendance_screen.dart';
import 'attendance_history_screen.dart';
import 'create_user/create_user_screen.dart';
import 'package:attendancebuddy/admin/generate_classes_screen.dart';

import 'package:attendancebuddy/admin/batch/batch_list_screen.dart';
import 'package:attendancebuddy/create_class/create_batch_screen.dart';
import 'package:attendancebuddy/create_class/create_subject_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Attendance Buddy\nAdmin Panel",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),

          /// ================= ATTENDANCE =================
          _navTile(
            context,
            "Today Attendance",
            Icons.today,
            const PresentStudentsScreen(),
          ),

          _navTile(
            context,
            "Attendance History",
            Icons.history,
            const AttendanceHistoryScreen(),
          ),

          const Divider(),

          /// ================= USERS =================
          _navTile(
            context,
            "Manage Users",
            Icons.people,
            const CreateUserScreen(),
          ),

          const Divider(),

          /// ================= BATCH MANAGEMENT =================
          _navTile(
            context,
            "Create Batch",
            Icons.add_box,
            const CreateBatchScreen(),
          ),

          _navTile(
            context,
            "Batch Management",
            Icons.group_work,
            const BatchListScreen(),
          ),

          const Divider(),

          /// ================= SUBJECT MANAGEMENT =================
          _navTile(
            context,
            "Create Subject",
            Icons.menu_book,
            const CreateSubjectScreen(),
          ),

          const Divider(),

          /// ================= LOCATION =================
          _navTile(
            context,
            "Room Locations",
            Icons.location_on,
             GenerateClassScreen(),
          ),
        ],
      ),
    );
  }

  /// 🔹 Common Navigation Tile
  Widget _navTile(
      BuildContext context,
      String title,
      IconData icon,
      Widget screen,
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }
}