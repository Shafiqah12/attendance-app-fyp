import 'dart:convert';
import 'package:http/http.dart' as http;

// ==================== MODELS ====================

class Student {
  final String id;
  final String studentName;
  final String studentRegistrationNumber;
  final String? className;
  
  Student({
    required this.id,
    required this.studentName,
    required this.studentRegistrationNumber,
    this.className,
  });
}

class EnrolledStudent {
  final String id;
  final String studentName;
  final String studentRegistrationNumber;
  final String enrollmentId;
  
  EnrolledStudent({
    required this.id,
    required this.studentName,
    required this.studentRegistrationNumber,
    required this.enrollmentId,
  });
}

class AttendanceRecord {
  final String studentId;
  final String date;
  final String status;
  
  AttendanceRecord({
    required this.studentId,
    required this.date,
    required this.status,
  });
}

// ==================== API SERVICE ====================

class ApiService {
  // Guna 10.0.2.2 untuk Android USB debugging
  static const String baseUrl = 'http://10.159.158.231:5000';
  
  // ==================== AUTHENTICATION ====================
  
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  static Future<Map<String, dynamic>?> signup(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }
  
  // ==================== CLASSES ====================
  
  static Future<List<dynamic>> getClasses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes?userId=$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Error getting classes: $e');
      return [];
    }
  }
  
  static Future<Map<String, dynamic>?> getClassLocation(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting class location: $e');
      return null;
    }
  }
  
  static Future<String> getClassName(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['class_name'] ?? data['courseName'] ?? 'Unknown Class';
      }
      return 'Unknown Class';
    } catch (e) {
      print('Error getting class name: $e');
      return 'Unknown Class';
    }
  }
  
  static Future<bool> addClass(Map<String, dynamic> classData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/classes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(classData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding class: $e');
      return false;
    }
  }
  
  static Future<bool> updateClass(String classId, Map<String, dynamic> classData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/classes/$classId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(classData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating class: $e');
      return false;
    }
  }
  
  static Future<bool> deleteClass(String classId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/classes/$classId'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting class: $e');
      return false;
    }
  }
  
  // ==================== STUDENTS ====================
  
  static Future<List<Student>> getStudents(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/students?userId=$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Student(
          id: json['id'].toString(),
          studentName: json['name'] ?? '',
          studentRegistrationNumber: json['reg_number'] ?? '',
          className: json['class_name'],
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }
  
  static Future<List<Student>> getAllStudents(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/students/all?userId=$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Student(
          id: json['id'].toString(),
          studentName: json['name'] ?? '',
          studentRegistrationNumber: json['reg_number'] ?? '',
          className: json['class_name'],
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting all students: $e');
      return [];
    }
  }
  
  static Future<bool> addStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/students'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(studentData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding student: $e');
      return false;
    }
  }
  
  static Future<bool> deleteStudent(String studentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/students/$studentId'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }
  
  // ==================== ENROLLMENTS ====================
  
  static Future<List<EnrolledStudent>> getEnrolledStudents(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId/enrolled-students'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => EnrolledStudent(
          id: json['studentId'].toString(),
          studentName: json['studentName'] ?? '',
          studentRegistrationNumber: json['registrationNumber'] ?? '',
          enrollmentId: json['enrollmentId'].toString(),
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting enrolled students: $e');
      return [];
    }
  }
  
  static Future<bool> enrollStudent(String classId, String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/classes/$classId/enroll'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'studentId': studentId}),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error enrolling student: $e');
      return false;
    }
  }
  
  static Future<bool> unenrollStudent(String enrollmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/enrollments/$enrollmentId'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error unenrolling student: $e');
      return false;
    }
  }
  
  // ==================== ATTENDANCE ====================
  
  static Future<List<AttendanceRecord>> getAttendanceDates(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId/attendance/dates'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AttendanceRecord(
          studentId: json['studentId'].toString(),
          date: json['date'],
          status: json['status'] ?? '',
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting attendance dates: $e');
      return [];
    }
  }
  
  static Future<bool> saveAttendance(String classId, String date, List<Map<String, dynamic>> attendanceData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/classes/$classId/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date,
          'attendance': attendanceData,
        }),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error saving attendance: $e');
      return false;
    }
  }
}