import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin_menu_tile.dart';
import 'my_classes_screen.dart';
import 'today_attendance_screen.dart';
import 'attendance_history_screen.dart';

import 'create_user/create_user_screen.dart';
import 'package:attendancebuddy/admin/user_list/user_list_screen.dart';
import '../create_class/create_class_screen.dart';
import 'package:attendancebuddy/admin/generate_classes_screen.dart';
import '../create_class/create_batch_screen.dart';
import 'package:attendancebuddy/admin/class_list_screen.dart';
import 'package:attendancebuddy/create_class/create_subject_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _adminDrawer(context),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {},
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            /// ================= WELCOME =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: 40, color: Colors.white),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Admin 👋",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Attendance Control Panel",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= CLASSES =================
            const _SectionTitle("Classes"),

            AdminMenuTile(
              title: "Create Attendance Class",
              icon: Icons.add_box,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateTodayAttendanceScreen(),
                  ),
                );
              },
            ),

            AdminMenuTile(
              title: "My Classes (Live Today)",
              icon: Icons.class_,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyClassesScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// ================= USERS =================
            const _SectionTitle("Users"),

            AdminMenuTile(
              title: "Create Users",
              icon: Icons.person_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateUserScreen(),
                  ),
                );
              },
            ),

            AdminMenuTile(
              title: "Users List",
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserListScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// ================= ATTENDANCE =================
            const _SectionTitle("Attendance"),

            AdminMenuTile(
              title: "Today Attendance",
              icon: Icons.today,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PresentStudentsScreen(),
                  ),
                );
              },
            ),

            AdminMenuTile(
              title: "Attendance History",
              icon: Icons.assignment,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceHistoryScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ================= DRAWER =================
  Drawer _adminDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Admin"),
            accountEmail: Text("admin@attendance.com"),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person, size: 30),
            ),
          ),

          Expanded(
            child: ListView(
              children: [

                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text("Dashboard"),
                  onTap: () => Navigator.pop(context),
                ),

                ListTile(
                  leading: const Icon(Icons.groups),
                  title: const Text("Create / Manage Batches"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateBatchScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text("Create Subject"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateSubjectScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.class_),
                  title: const Text("Class List"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClassHistoryScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text("Users"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserListScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text("Room Location"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenerateClassScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content:
                  const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.popUntil(
                      context, (route) => route.isFirst);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

/// ================= SECTION TITLE =================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}