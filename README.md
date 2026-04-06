# attendify — Student Attendance Mobile App

**Mobile app to manage students, classes, attendance and generate Excel reports (Flutter + Firebase).**

---

## Table of contents
- [Project overview](#project-overview)  
- [Key features](#key-features)  
- [Screens / UX flow](#screens--ux-flow)  
- [Firestore data model (brief)](#firestore-data-model-brief)  
- [How it works (behavior & important rules)](#how-it-works-behavior--important-rules)  
- [Setup & run locally](#setup--run-locally)  
- [Permissions](#permissions)  
- [Architecture & diagram explanation](#architecture--diagram-explanation)  
- [Support documentation mapping (UI → DB actions)](#support-documentation-mapping-ui--db-actions)  
- [Known limitations & suggested improvements](#known-limitations--suggested-improvements)  
- [Contributing](#contributing)  
- [License](#license)

---

## Project overview

**Name:** `attendify` — Mobile Application for Attendance Management

**Purpose:** Simplify attendance workflows for instructors and small schools: manage student records, create classes, enroll students, mark attendance (once per day), and export attendance reports to Excel.

---

## Key features
- Email/password authentication (signup & login).  
- Dashboard with quick access to Students, Classes, Reports, Profile.  
- CRUD for Students and Classes.  
- Enroll / unenroll students in classes.  
- Mark attendance for enrolled students (enforced once per day).  
- View / edit / delete attendance entries.  
- Export class attendance for a date range to Excel (saved to device downloads).  
- Edit user profile (first/last name).

---

## Screens / UX flow
- **Signup** — first name, last name, email, password, confirm password → creates user account.  
- **Login** — email + password → opens dashboard.  
- **Dashboard** — cards linking to Students, Classes, Reports, Profile.  
- **Students** — list, add, edit, delete students.  
- **Classes** — list, add, edit, delete classes; view enrolled students and attendance.  
- **Enroll Student** — choose from students not already enrolled and add to a class.  
- **Mark Attendance** — mark present/absent for enrolled students (only once per day).  
- **Reports** — select class + date range → generate Excel file, save to device downloads.  
- **Profile** — edit first and last name.

---

## Firestore data model (brief)

**Key collections and fields**

- `users` (document id = `<userUid>`)  
  - `createdAt` (Timestamp)  
  - `email`  
  - `firstName`  
  - `lastName`

- `Students` (document id = `<studentId>`)  
  - `name`  
  - `ownerUid`  
  - `registrationNumber`  
  - `enrolledAt` (Timestamp)

- `classes` (document id = `<classId>`)  
  - `courseName`  
  - `ownerUid`  
  - `startingDate` / `endingDate`  
  - `createdBy` (UID)

  - **subcollection `enrolledStudents`**  
    - doc id = `<studentId>`  
    - `name`  
    - `registrationNumber`  
    - `enrolledAt` (Timestamp)

  - **subcollection `attendance`**  
    - doc id = `<date>` (ISO date string, e.g. `2025-05-24`)  
    - Fields per student attendance entry: `status` (`"P"`/`"A"`), `markedAt` (Timestamp)

**Common paths**
- `/classes/{classId}/enrolledStudents/{studentId}`  
- `/classes/{classId}/attendance/{YYYY-MM-DD}`

---

## How it works (behavior & important rules)
- **Authentication:** Email/password accounts handled by Firebase Authentication; user metadata stored in `users/{uid}`.  
- **Student enrollment:** Students live as documents in `Students`. Enrolling copies a snapshot of student info into `/classes/{classId}/enrolledStudents/` so class-level snapshots remain stable even if the original student document changes later.  
- **Attendance marking rule:** The app enforces one attendance mark per class per day by checking `/classes/{classId}/attendance/{YYYY-MM-DD}` — if an attendance document for that date exists, marking is blocked and the user is notified.  
- **Reporting:** Selecting class + date range reads the relevant attendance documents and exports an Excel file to the device after required file-permission checks.  
- **Profile updates:** Editing profile fields updates `users/{uid}` accordingly.

---

## Setup & run locally

### Prerequisites
- Flutter SDK (stable channel).  
- Android SDK / Xcode (for Android / iOS testing).  
- A Firebase project with:
  - Authentication enabled (Email/Password).  
  - Cloud Firestore enabled.

### Steps
1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure Firebase for the app:
- Create a Firebase project and enable Authentication (Email/Password) and Firestore.  
- Add Android and/or iOS apps in the Firebase console.  
- Download platform configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) and place them in the appropriate platform folders.  
- If the project expects `firebase_options.dart`, generate it (e.g., using flutterfire CLI) and include it in `/lib`.

3. Run the app on a device or emulator:
```bash
flutter run
```

**Notes**
- Make sure `firebase_options.dart` (if used) is present and correctly configured.  
- During development, Firestore rules may be relaxed for convenience — tighten them before publishing to production.

---

## Permissions
- **Android:** Request runtime file storage access to save Excel reports to Downloads.  
- **iOS:** Configure file saving/document picker entitlements if saving to Files.

---

## Architecture & diagram explanation

### Components
- **Mobile client (Flutter UI):** all screens and UX for authentication, managing students/classes, marking attendance, and report generation.  
- **Firebase Authentication:** handles user sign-up and sign-in.  
- **Cloud Firestore:** primary backend storing `users`, `Students`, `classes`, and subcollections `enrolledStudents` and `attendance`.  
- **Local device storage:** used to save generated Excel files (Downloads or Files).

### Data & control flows
- **Signup / Login** — client uses Firebase Auth; on successful signup, create a `users/{uid}` document with `firstName`, `lastName`, `email`, and `createdAt`.  
- **Student CRUD** — create/edit/delete operations update `Students` collection.  
- **Class CRUD and Enrollment** — create class docs in `classes`; enrolling creates a snapshot in `/classes/{classId}/enrolledStudents/{studentId}` to preserve enrollment state.  
- **Attendance** — when marking attendance the client checks for `/classes/{classId}/attendance/{YYYY-MM-DD}`. If not found, it writes attendance data; if found, it prevents duplicate marking. Attendance entries include `status` and `markedAt`.  
- **Report generation** — client reads attendance entries over a date range and assembles an Excel file for export.  
- **Profile updates** — updates reflected in `users/{uid}`.

### Design rationale
- Storing `enrolledStudents` as a subcollection simplifies fetching class rosters and keeps class-specific student snapshots stable.  
- Using date-keyed documents for attendance makes it simple to check whether attendance has already been taken for a given day.  
- Copying student info into `enrolledStudents` ensures historical accuracy of class rosters.

---

## Support documentation mapping (UI → DB actions)
- **Signup** → create `users/{uid}`.  
- **Login** → Firebase Auth → fetch `users/{uid}`.  
- **Add student** → create document in `Students`.  
- **Edit student** → update `Students/{studentId}`.  
- **Delete student** → delete `Students/{studentId}` (consider whether to cascade or flag enrollments).  
- **Add class** → create `classes/{classId}`.  
- **Enroll student** → create `classes/{classId}/enrolledStudents/{studentId}` (copy of student data).  
- **Mark attendance** → write to `classes/{classId}/attendance/{YYYY-MM-DD}` (entries + `markedAt`).  
- **Generate report** → read `/classes/{classId}/attendance/*` within date range → export to Excel.

---

## Known limitations & suggested improvements
- **Concurrency / race conditions:** If multiple users mark attendance simultaneously for the same class, consider server-side transactions or cloud functions to avoid race conditions.  
- **Multiple sessions per day:** If you need multiple attendance sessions per day, extend the attendance key to include session id/time.  
- **Search & filters:** Add search by name or registration number and improved filtering on Students/Class lists.  
- **Offline support:** Add local caching + sync so teachers can mark attendance offline and sync later.  
- **Security rules:** Implement Firestore security rules that restrict access to owners or authorized users only.  
- **Testing & logging:** Add automated tests and structured logging for easier troubleshooting.

---

## Contributing
- Create a branch for your feature or fix.  
- Implement changes and add tests where appropriate.  
- Submit your changes for review.

---

## License

Choose a license for your project (MIT is a common, permissive choice). Example header:

```
MIT License
© [2025] [MursalBajwa]
Permission is hereby granted, free of charge, to any person obtaining a copy...
```

---

## Appendix — Example Firestore structure (sample)
```text
users/
  <uid>:
    firstName: "Ali"
    lastName: "Khan"
    email: "ali@example.com"
    createdAt: Timestamp

Students/
  <studentId>:
    name: "Ayesha"
    registrationNumber: "REG123"
    ownerUid: "<uid>"

classes/
  <classId>:
    courseName: "Math 101"
    ownerUid: "<uid>"

classes/<classId>/enrolledStudents/<studentId>:
  name: "Ayesha"
  registrationNumber: "REG123"
  enrolledAt: Timestamp

classes/<classId>/attendance/2025-08-11:
  <studentId>: { status: "P", markedAt: Timestamp }
```
