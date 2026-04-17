import 'package:attendify/Parts/appDrawer.dart';
import 'package:attendify/Parts/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'util/appRoutes.dart';
import 'Theme/apptheme.dart';

// Dashboard menu items
List<GridItem> items = [
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
  )
];

class CrDashboard extends StatelessWidget {
  const CrDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTh = theme.textTheme;

    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Dashboard',
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            childAspectRatio: 0.7,
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