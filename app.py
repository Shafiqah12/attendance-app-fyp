from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import hashlib
from datetime import datetime, timedelta
import os
import random
import string

app = Flask(__name__)
CORS(app)

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()

# Database setup
def init_db():
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            nfc_id TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS classes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            class_name TEXT NOT NULL,
            lecturer_id INTEGER NOT NULL,
            schedule TEXT,
            room TEXT,
            starting_date TEXT,
            ending_date TEXT,
            owner_uid TEXT,
            latitude REAL,
            longitude REAL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (lecturer_id) REFERENCES users (id)
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS enrollments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (student_id) REFERENCES users (id),
            FOREIGN KEY (class_id) REFERENCES classes (id),
            UNIQUE(student_id, class_id)
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            marked_by TEXT DEFAULT 'student',
            marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (student_id) REFERENCES users (id),
            FOREIGN KEY (class_id) REFERENCES classes (id),
            UNIQUE(student_id, class_id, date)
        )
    ''')
    
    conn.commit()
    conn.close()

active_qr_codes = {}

# ==================== AUTHENTICATION ====================

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({'success': False, 'error': 'Email and password required'}), 400
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    cursor.execute('SELECT id, email, password, name, role, nfc_id FROM users WHERE email = ?', (email,))
    user = cursor.fetchone()
    conn.close()
    
    if user and user[2] == hash_password(password):
        return jsonify({
            'success': True,
            'user': {
                'id': user[0],
                'email': user[1],
                'name': user[3],
                'role': user[4],
                'nfcId': user[5]
            }
        })
    
    return jsonify({'success': False, 'error': 'Invalid credentials'}), 401

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')
    role = data.get('role', 'student')
    
    if not email or not password or not name:
        return jsonify({'success': False, 'error': 'All fields required'}), 400
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            'INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)',
            (email, hash_password(password), name, role)
        )
        conn.commit()
        user_id = cursor.lastrowid
        conn.close()
        
        return jsonify({
            'success': True,
            'user': {'id': user_id, 'email': email, 'name': name, 'role': role}
        })
    except sqlite3.IntegrityError:
        conn.close()
        return jsonify({'success': False, 'error': 'Email already exists'}), 400

@app.route('/api/students/by-nfc', methods=['GET'])
def get_student_by_nfc():
    nfc_id = request.args.get('nfcId')
    if not nfc_id:
        return jsonify({'error': 'NFC ID required'}), 400
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    cursor.execute('SELECT id, name, email, role FROM users WHERE nfc_id = ?', (nfc_id,))
    student = cursor.fetchone()
    conn.close()
    
    if student:
        return jsonify({'id': student[0], 'name': student[1], 'email': student[2], 'role': student[3]})
    return jsonify({'error': 'Student not found'}), 404

# ==================== CLASSES ====================

@app.route('/api/classes', methods=['GET'])
def get_classes():
    user_id = request.args.get('userId')
    role = request.args.get('role')
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    
    try:
        if role == 'lecturer':
            cursor.execute('SELECT id, class_name, latitude, longitude FROM classes WHERE lecturer_id = ?', (user_id,))
        else:
            cursor.execute('''
                SELECT c.id, c.class_name, c.latitude, c.longitude 
                FROM classes c
                JOIN enrollments e ON c.id = e.class_id
                WHERE e.student_id = ?
            ''', (user_id,))
        
        classes = cursor.fetchall()
        conn.close()
        
        return jsonify([{
            'id': c[0],
            'name': c[1],
            'latitude': c[2],
            'longitude': c[3]
        } for c in classes])
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500

@app.route('/api/classes', methods=['POST'])
def create_class():
    data = request.get_json()
    print(f"📥 Received: {data}")
    
    # Support BOTH 'name' and 'courseName' from apps
    class_name = data.get('name') or data.get('courseName')
    lecturer_id = data.get('lecturerId') or data.get('ownerUid')
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    
    print(f"📝 Class name: {class_name}, Lecturer: {lecturer_id}")
    
    if not class_name or not lecturer_id:
        return jsonify({
            'success': False, 
            'error': f'Missing: name={class_name}, lecturer={lecturer_id}'
        }), 400
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    
    try:
        cursor.execute('''
            INSERT INTO classes (class_name, lecturer_id, latitude, longitude)
            VALUES (?, ?, ?, ?)
        ''', (class_name, lecturer_id, latitude, longitude))
        
        conn.commit()
        class_id = cursor.lastrowid
        conn.close()
        
        print(f"✅ Class created: {class_name} (ID: {class_id})")
        
        # FORMAT RESPONSE YANG APPS HARAPKAN
        return jsonify({
            'success': True,
            'message': 'Class added successfully',
            'classId': class_id,
            'className': class_name,
            'code': f'CLASS-{class_id}',
            'latitude': latitude,
            'longitude': longitude
        }), 200
        
    except Exception as e:
        conn.close()
        print(f"❌ Error: {e}")
        return jsonify({
            'success': False, 
            'error': str(e)
        }), 500

@app.route('/api/classes/<class_id>/location', methods=['GET'])
def get_class_location(class_id):
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    cursor.execute('SELECT latitude, longitude FROM classes WHERE id = ?', (class_id,))
    location = cursor.fetchone()
    conn.close()
    
    if location:
        return jsonify({'latitude': location[0], 'longitude': location[1]})
    return jsonify({'error': 'Class not found'}), 404

@app.route('/api/classes/<class_id>/name', methods=['GET'])
def get_class_name(class_id):
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    cursor.execute('SELECT class_name FROM classes WHERE id = ?', (class_id,))
    result = cursor.fetchone()
    conn.close()
    
    if result:
        return jsonify({'name': result[0]})
    return jsonify({'error': 'Class not found'}), 404

@app.route('/api/classes/<class_id>/students', methods=['GET'])
def get_enrolled_students(class_id):
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    cursor.execute('''
        SELECT u.id, u.name, u.email 
        FROM users u
        JOIN enrollments e ON u.id = e.student_id
        WHERE e.class_id = ? AND u.role = 'student'
    ''', (class_id,))
    students = cursor.fetchall()
    conn.close()
    
    return jsonify([{'id': s[0], 'name': s[1], 'email': s[2]} for s in students])

# ==================== ATTENDANCE ====================

@app.route('/api/attendance/save', methods=['POST'])
def save_attendance():
    data = request.get_json()
    class_id = data.get('classId')
    date = data.get('date')
    attendance_list = data.get('attendance', [])
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    
    for record in attendance_list:
        student_id = record.get('studentId')
        status = record.get('status')
        
        cursor.execute('''
            INSERT OR REPLACE INTO attendance (student_id, class_id, date, status)
            VALUES (?, ?, ?, ?)
        ''', (student_id, class_id, date, status))
    
    conn.commit()
    conn.close()
    
    return jsonify({'success': True})

@app.route('/api/attendance/check', methods=['GET'])
def check_attendance():
    student_id = request.args.get('studentId')
    class_id = request.args.get('classId')
    date = request.args.get('date')
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    cursor.execute(
        'SELECT status FROM attendance WHERE student_id = ? AND class_id = ? AND date = ?',
        (student_id, class_id, date)
    )
    result = cursor.fetchone()
    conn.close()
    
    return jsonify({'status': result[0] if result else 'A'})

# ==================== QR CODE ====================

@app.route('/api/attendance/qr/generate', methods=['POST'])
def generate_qr():
    data = request.get_json()
    class_id = data.get('classId')
    token = data.get('token')
    
    active_qr_codes[token] = {
        'classId': class_id,
        'expiresAt': (datetime.now() + timedelta(minutes=5)).isoformat(),
        'used': False
    }
    
    print(f"✅ QR Generated for class {class_id}")
    return jsonify({'success': True, 'token': token})

@app.route('/api/attendance/qr/verify', methods=['POST'])
def verify_qr():
    data = request.get_json()
    token = data.get('token')
    student_id = data.get('studentId')
    class_id = data.get('classId')
    date = data.get('date')
    
    if token not in active_qr_codes:
        return jsonify({'success': False, 'error': 'Invalid QR'}), 400
    
    qr = active_qr_codes[token]
    
    if datetime.now() > datetime.fromisoformat(qr['expiresAt']):
        return jsonify({'success': False, 'error': 'QR expired'}), 400
    
    if qr['used']:
        return jsonify({'success': False, 'error': 'QR already used'}), 400
    
    if str(qr['classId']) != str(class_id):
        return jsonify({'success': False, 'error': 'Wrong class'}), 400
    
    active_qr_codes[token]['used'] = True
    
    conn = sqlite3.connect('attendance.db')
    cursor = conn.cursor()
    cursor.execute('''
        INSERT OR REPLACE INTO attendance (student_id, class_id, date, status, marked_by)
        VALUES (?, ?, ?, ?, ?)
    ''', (student_id, class_id, date, 'P', 'qr'))
    conn.commit()
    conn.close()
    
    print(f"✅ QR Attendance recorded for student {student_id}")
    return jsonify({'success': True})

# ==================== HEALTH ====================

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

# ==================== START SERVER ====================
if __name__ == '__main__':
    init_db()
    print("🚀 Server ready!")
    print("✅ POST /api/classes - READY (supports 'name' or 'courseName')")
    print("✅ GET /api/classes - READY")
    print("✅ QR endpoints - READY")
    
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)