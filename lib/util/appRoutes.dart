import 'package:flutter/material.dart';
import 'package:attendify/crDashboard.dart';
import 'package:attendify/classesView.dart';
import 'package:attendify/generateReports.dart';
import 'package:attendify/studentView.dart';
import 'package:attendify/profileView.dart';
import 'package:attendify/addStudent.dart';
import 'package:attendify/addClass.dart';
import 'package:attendify/attendanceView.dart';
import 'package:attendify/markAttendanceView.dart';
import 'package:attendify/enrollStudents.dart';
import 'package:attendify/editProfile.dart';
import 'package:attendify/editStudent.dart';
import 'package:attendify/editClass.dart';
import 'package:attendify/editAttendenceView.dart';
import 'package:attendify/viewAttendenceView.dart';
import 'package:attendify/addEnrolledStudent.dart';
import 'package:attendify/loginpage.dart';
import 'package:attendify/signUp.dart';
import 'package:attendify/write_nfc.dart';
import 'package:attendify/test_nfc.dart';

class appRoutes {
  static const String loginPage = "/";
  static const String signupPage = "/signup";
  static const String crDashboardPage = "/crdashboard";
  static const String classesPage = "/classes";
  static const String generateReportPage = "/report";
  static const String studentsPage = "/students";
  static const String profilePage = "/profile";
  static const String addStudentPage = "/addstudent";
  static const String addClassPage = "/addclass";
  static const String attendancePage = "/attendance";
  static const String markAttendance = "/markattendance";
  static const String enrollStudentPage = "/enrollStudent";
  static const String editProfilePage = "/editprofile";
  static const String editStudentPage = "/editstudent";
  static const String editClassPage = "/editclass";
  static const String editAttendanceViewPage = "/editAttendance";
  static const String viewAttendanceViewPage = "/viewAttendance";
  static const String addEnrolledStudentPage = "/addEnrolledStudentPage";
  static const String writeNFCPage = "/writenfc";
  // Dalam class appRoutes:
  static const String testNFCPage = "/testnfc";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case appRoutes.loginPage:
        return MaterialPageRoute(builder: (c) => const LoginPage());
        
      case appRoutes.signupPage:
        return MaterialPageRoute(builder: (c) => const SignUpPage());
        
      case appRoutes.crDashboardPage:
        return MaterialPageRoute(builder: (c) => const CrDashboard());
        
      case appRoutes.classesPage:
        return MaterialPageRoute(builder: (c) => const ClassesViewPage());
        
      case appRoutes.generateReportPage:
        return MaterialPageRoute(builder: (c) => const GenerateReports());
        
      case appRoutes.studentsPage:
        return MaterialPageRoute(builder: (c) => const StudentViewPage());
        
      case appRoutes.profilePage:
        return MaterialPageRoute(builder: (c) => const ProfileView());
        
      case appRoutes.addStudentPage:
        return MaterialPageRoute(builder: (c) => const AddStudentPage());
        
      case appRoutes.addClassPage:
        return MaterialPageRoute(builder: (c) => const AddClassPage());
        
      case appRoutes.attendancePage:
        final classId = settings.arguments as String?;
        return MaterialPageRoute(builder: (c) => AttendanceViewPage(classId: classId ?? ''));
        
      case appRoutes.markAttendance:
        final classId = settings.arguments as String?;
        return MaterialPageRoute(builder: (c) => MarkAttendanceView(classId: classId ?? ''));
        
      case appRoutes.enrollStudentPage:
        final classId = settings.arguments as String?;
        return MaterialPageRoute(builder: (c) => EnrollStudentsPage(classId: classId ?? ''));
        
      case appRoutes.editProfilePage:
        return MaterialPageRoute(builder: (c) => const EditProfile());
        
      case appRoutes.editStudentPage:
        final args = settings.arguments as Map<String, dynamic>?;
        final studentId = args?['studentId'] as String?;
        return MaterialPageRoute(builder: (c) => EditStudentPage(studentId: studentId));
        
      case appRoutes.editClassPage:
        final classId = settings.arguments as String?;
        return MaterialPageRoute(builder: (c) => EditClassPage(classId: classId ?? ''));
        
      case appRoutes.editAttendanceViewPage:
        final args = settings.arguments as Map<String, String>?;
        final classId = args?['classId'] ?? '';
        final attendanceDate = args?['Date'] ?? '';
        return MaterialPageRoute(builder: (c) => EditAttendanceView(
          classId: classId,
          attendanceDate: attendanceDate,
        ));
        
      case appRoutes.viewAttendanceViewPage:
        final args = settings.arguments as Map<String, dynamic>?;
        final classId = args?['classId'] as String? ?? '';
        final attendanceDate = args?['Date'] as String? ?? '';
        return MaterialPageRoute(builder: (c) => ViewAttendanceView(
          classId: classId,
          attendanceDate: attendanceDate,
        ));
        
      case appRoutes.addEnrolledStudentPage:
        final classId = settings.arguments as String?;
        return MaterialPageRoute(builder: (c) => AddEnrolledStudent(classId: classId));
      
      case appRoutes.writeNFCPage:
        return MaterialPageRoute(builder: (c) => const WriteNFCPage());
      
      // Dalam generateRoute:
      case appRoutes.testNFCPage:
       return MaterialPageRoute(builder: (c) => const TestNFCPage());

      default:
        return MaterialPageRoute(
          builder: (c) => const Scaffold(
            body: Center(
              child: Text("Page Does Not Exist"),
            ),
          ),
        );
    }
  }
}