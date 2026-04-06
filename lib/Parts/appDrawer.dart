import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendify/services/auth_service.dart';
import 'package:attendify/util/appRoutes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userRole = authService.userRole;
    final userName = authService.userName ?? 'User';
    final userEmail = authService.userEmail ?? '';

    return Drawer(
      child: Column(
        children: [
          // Header with user info
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              children: [
                // Dashboard
                ListTile(
                  leading: Icon(Icons.dashboard),
                  title: Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, appRoutes.crDashboardPage);
                  },
                ),
                
                // Classes (for lecturers)
                if (userRole == 'lecturer' || userRole == 'admin')
                  ListTile(
                    leading: Icon(Icons.class_),
                    title: Text('Classes'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, appRoutes.classesPage);
                    },
                  ),
                
                // Students (for lecturers)
                if (userRole == 'lecturer' || userRole == 'admin')
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Students'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, appRoutes.studentsPage);
                    },
                  ),
                
                // Attendance
                ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('Attendance'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to attendance view
                  },
                ),
                
                // Reports
                if (userRole == 'lecturer' || userRole == 'admin')
                  ListTile(
                    leading: Icon(Icons.bar_chart),
                    title: Text('Reports'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, appRoutes.generateReportPage);
                    },
                  ),
                
                // Profile
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, appRoutes.profilePage);
                  },
                ),
                
                Divider(),
                
                // Logout
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await authService.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, appRoutes.loginPage);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}