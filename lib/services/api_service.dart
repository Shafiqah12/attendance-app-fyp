import 'dart:convert';
import 'package:http/http.dart' as http;

// ==================== MODELS ====================

class Class {
  final String id;
  final String courseName;
  final String startingDate;
  final String endingDate;
  final String? schedule;
  final String? room;

  Class({
    required this.id,
    required this.courseName,
    required this.startingDate,
    required this.endingDate,
    this.schedule,
    this.room,
  });
}

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

class AttendanceRecordForView {
  final String studentId;
  final String studentName;
  final String studentRegistrationNumber;
  final String status;
  
  AttendanceRecordForView({
    required this.studentId,
    required this.studentName,
    required this.studentRegistrationNumber,
    required this.status,
  });
}

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? role;
  
  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.role,
  });
  
  String get fullName => '$firstName $lastName';
}

// ==================== API SERVICE ====================

class ApiService {
  // 🔧 IMPORTANT: Replace with your computer's IP address!
  static const String baseUrl = 'http://10.62.53.69:5000';  // Your IP from above
  
  // ==================== AUTHENTICATION ====================
  
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
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
  
  static Future<List<Class>> getClasses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes?userId=$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Class(
          id: json['id'].toString(),
          courseName: json['class_name'] ?? json['courseName'] ?? '',
          startingDate: json['starting_date'] ?? json['startingDate'] ?? '',
          endingDate: json['ending_date'] ?? json['endingDate'] ?? '',
          schedule: json['schedule'],
          room: json['room'],
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting classes: $e');
      return [];
    }
  }
  
  static Future<Class?> getClassById(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Class(
          id: data['id'].toString(),
          courseName: data['class_name'] ?? data['courseName'] ?? '',
          startingDate: data['starting_date'] ?? data['startingDate'] ?? '',
          endingDate: data['ending_date'] ?? data['endingDate'] ?? '',
          schedule: data['schedule'],
          room: data['room'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting class: $e');
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
  
  static Future<Student?> getStudentById(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/students/$studentId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Student(
          id: data['id'].toString(),
          studentName: data['name'] ?? '',
          studentRegistrationNumber: data['reg_number'] ?? '',
          className: data['class_name'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting student: $e');
      return null;
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
  
  static Future<bool> updateStudent(String studentId, Map<String, dynamic> studentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/students/$studentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(studentData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating student: $e');
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
  
  static Future<bool> unenrollStudentByStudentId(String classId, String studentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/classes/$classId/students/$studentId/enrollment'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error unenrolling student by ID: $e');
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
  
  static Future<bool> checkAttendanceExists(String classId, String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId/attendance/check?date=$date'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking attendance: $e');
      return false;
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
  
  static Future<bool> deleteAttendanceByDate(String classId, String date) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/classes/$classId/attendance/$date'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting attendance: $e');
      return false;
    }
  }
  
  static Future<List<AttendanceRecordForView>> getAttendanceForDate(String classId, String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId/attendance/date/$date'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AttendanceRecordForView(
          studentId: json['studentId'].toString(),
          studentName: json['studentName'] ?? '',
          studentRegistrationNumber: json['registrationNumber'] ?? '',
          status: json['status'] ?? 'A',
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting attendance for date: $e');
      return [];
    }
  }
  
  static Future<String> getAttendanceStatus(String classId, String studentId, String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId/students/$studentId/attendance?date=$date'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] ?? 'A';
      }
      return 'A';
    } catch (e) {
      print('Error getting attendance status: $e');
      return 'A';
    }
  }
  
  static Future<List<AttendanceRecord>> getAttendanceForDateRange(String classId, DateTime from, DateTime to) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes/$classId/attendance?from=${from.toIso8601String()}&to=${to.toIso8601String()}'),
      ).timeout(const Duration(seconds: 30));
      
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
      print('Error getting attendance for date range: $e');
      return [];
    }
  }
  
  // ==================== USER PROFILE ====================
  
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfile(
          firstName: data['firstName'] ?? data['name']?.split(' ')[0] ?? '',
          lastName: data['lastName'] ?? 
              (data['name']?.split(' ').length > 1 
                  ? data['name'].split(' ').sublist(1).join(' ') 
                  : ''),
          email: data['email'] ?? '',
          phone: data['phone'],
          role: data['role'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
  
  static Future<bool> updateUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profileData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}