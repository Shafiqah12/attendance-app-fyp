import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/Parts/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'util/appRoutes.dart';
import 'Theme/apptheme.dart';
import 'package:attendify/services/auth_service.dart';

// Dashboard menu items for Lecturer
List<GridItem> lecturerItems = [
  GridItem(
    title: "Students",
    img: "student.png",
    function: (context) {
      Navigator.pushNamed(context, appRoutes.studentsPage);
    },
  ),
  GridItem(
    title: "Classes",
    img: "Class.png",
    function: (context) {
      Navigator.pushNamed(context, appRoutes.classesPage);
    },
  ),
  GridItem(
    title: "Report",
    img: "report.png",
    function: (context) {
      Navigator.pushNamed(context, appRoutes.generateReportPage);
    },
  ),
  GridItem(
    title: "Profile",
    img: "profile.png",
    function: (context) {
      Navigator.pushNamed(context, appRoutes.profilePage);
    },
  ),
  GridItem(
    title: "Write NFC",
    img: null,
    icon: Icons.nfc,
    function: (context) {
      Navigator.pushNamed(context, appRoutes.writeNFCPage);
    },
  ),
  GridItem(
    title: "Test NFC",
    img: null,
    icon: Icons.nfc,
    function: (context) {
      Navigator.pushNamed(context, appRoutes.testNFCPage);
    },
  ),
];

// Dashboard menu items for Student
List<GridItem> studentItems = [
  GridItem(
    title: "My Classes",
    img: "Class.png",
    function: (context) {
      Navigator.pushNamed(context, appRoutes.classesPage);
    },
  ),
  GridItem(
    title: "My Attendance",
    img: "report.png",
    function: (context) {
      // Student can view their own attendance
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('My attendance feature coming soon')),
      );
    },
  ),
  GridItem(
    title: "Profile",
    img: "profile.png",
    function: (context) {
      Navigator.pushNamed(context, appRoutes.profilePage);
    },
  ),
];

class CrDashboard extends StatelessWidget {
  const CrDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    final isLecturer = authService.userRole == 'lecturer' || authService.userRole == 'admin';
    final items = isLecturer ? lecturerItems : studentItems;
    final dashboardTitle = isLecturer ? 'Lecturer Dashboard' : 'Student Dashboard';

    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          dashboardTitle,
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                items[index].function(context);
              },
              child: gridCardDashboard(item: items[index]),
            );
          },
        ),
      ),
    );
  }
}