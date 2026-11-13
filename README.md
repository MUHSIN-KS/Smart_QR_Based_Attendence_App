# Smart QR-Based Attendance Management App

A production-ready Flutter mobile application featuring **Clean Architecture**, **BLoC (Business Logic Component)** state management, **Dio** networking, and a custom **Node.js + Express + SQLite** REST API backend. Built for automated, tamper-resistant employee check-ins and check-outs with dynamic QR code validation and GPS location tracking.

---

## 🌟 Key Features

### 👤 Employee App
- **Authentication**: Secure JWT-based login, registration, and persistent sessions.
- **Dynamic Routing**: Automatic role detection directing employees to the Employee Workspace.
- **Today's Status Card**: Real-time display of current status (*Not Checked In*, *Checked In*, *Checked Out*, *Late*).
- **QR Attendance Scanner**: High-speed camera scanner using `mobile_scanner` with a manual input fallback for emulators.
- **GPS Location Tagging**: High-accuracy coordinate capture via `geolocator` (`10.0889° N, 77.0595° E`) during both check-in and check-out.
- **Attendance History**: Complete history log with on-time / late metrics, check-in/out timestamps, hours worked, and GPS location records.
- **Profile & Configuration**: User details and in-app backend server URL switcher.

### 🛡️ Admin Portal
- **Dashboard Metrics**: Real-time KPI cards displaying *Total Employees*, *Present Today*, *Absent / Pending*, and *Late Arrivals*.
- **Dynamic QR Generator**: Time-limited session generator (1, 2, 5, 10 minutes) with animated live countdown timer and expiration overlay using `qr_flutter`.
- **Live Attendance Logs**: Real-time audit log of all employee check-in and check-out events with GPS coordinates and timestamps.
- **Employee Directory**: Complete registry of company employees, departments, and onboarding dates.
- **Role-Based Security**: Administrative endpoints protected by role-checking middleware.

---

## 🏗️ Architecture & Technology Stack

```
smart_qr_based_attendance_app/
│
├── backend/                             # Custom Node.js + Express + SQLite REST API
│   ├── database.js                      # Built-in SQLite connection & auto-seeding
│   ├── server.js                        # Express server entry point (Port 3000)
│   ├── middleware/auth.js               # JWT verification & role validation
│   ├── routes/
│   │   ├── auth.js                      # /api/auth (login, register, profile)
│   │   ├── attendance.js                # /api/attendance (session, check-in, check-out, history)
│   │   └── admin.js                     # /api/admin (dashboard stats, records, directory)
│   ├── test_api.js                      # Automated endpoint test suite (12 test cases)
│   └── run_and_test.js                  # Standalone test runner
│
├── lib/                                 # Flutter Client (Clean Architecture + BLoC)
│   ├── core/
│   │   ├── constants/                   # Colors, App Constants, ApiEndpoints
│   │   ├── network/                     # Dio ApiClient with interceptors & ApiException
│   │   ├── services/                    # StorageService (Prefs) & LocationService (GPS)
│   │   ├── theme/                       # Material 3 typography, palettes & themes
│   │   └── utils/                       # DateTime formatters & Dialog utilities
│   │
│   ├── features/
│   │   ├── auth/                        # User & Admin Authentication
│   │   │   ├── data/                    # UserModel & AuthRepository
│   │   │   └── presentation/            # AuthBloc, LoginScreen, RegisterScreen, SplashScreen
│   │   │
│   │   ├── employee/                    # Employee Attendance & Scanner
│   │   │   ├── data/                    # AttendanceModel & AttendanceRepository
│   │   │   └── presentation/            # EmployeeAttendanceBloc, QrScannerBloc, Screens
│   │   │
│   │   └── admin/                       # Admin Dashboard & QR Generator
│   │       ├── data/                    # AdminDashboardModel, EmployeeModel, AdminRepository
│   │       └── presentation/            # AdminDashboardBloc, AdminQrBloc, Screens
│   │
│   └── main.dart                        # MultiBlocProvider & App Initialization
```

---

## 📡 REST API Specifications

### A. Authentication
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/auth/login` | Employee/Admin sign-in | No |
| `POST` | `/api/auth/register` | Employee account registration | No |
| `GET` | `/api/auth/profile` | Logged-in user details | Bearer JWT |

### B. QR Code Management (Admin)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/attendance/session` | Generate time-limited QR session | Admin JWT |
| `GET` | `/api/attendance/session/active` | Retrieve current active QR session | Bearer JWT |
| `GET` | `/api/attendance/session/:id` | Get specific session details | Bearer JWT |

### C. Employee Attendance
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/attendance/check-in` | Mark check-in with QR token & GPS | Employee JWT |
| `POST` | `/api/attendance/check-out` | Mark check-out with QR token & GPS | Employee JWT |
| `GET` | `/api/attendance/today` | Fetch logged-in user's today status | Employee JWT |
| `GET` | `/api/attendance/history` | Fetch individual attendance history | Employee JWT |

### D. Admin Dashboard
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/admin/dashboard` | Attendance KPI statistics | Admin JWT |
| `GET` | `/api/admin/employees` | List all employees | Admin JWT |
| `GET` | `/api/admin/attendance` | Full attendance records list | Admin JWT |
| `GET` | `/api/admin/attendance/:id` | Single record details | Admin JWT |

---

## 🛡️ Validation Scenarios & Status Codes

| Scenario | HTTP Status | Response Handling |
|---|---|---|
| **Valid QR Token** | `200 OK` / `201 Created` | Check-in/out successful; GPS and timestamp saved. |
| **Expired QR Code** | `400 Bad Request` | `"QR code expired. Please ask administrator to generate a new QR code."` |
| **Duplicate Check-in** | `409 Conflict` | `"Duplicate attendance: You have already checked in today"` |
| **Invalid QR Token** | `400 Bad Request` | `"Invalid QR code"` |
| **Check-out without Check-in** | `400 Bad Request` | `"Check-in required before checking out"` |
| **Already Checked Out** | `409 Conflict` | `"Already checked out for today"` |
| **Missing/Expired Auth** | `401 Unauthorized` | Prompts user to re-authenticate. |
| **Non-Admin QR Generation** | `403 Forbidden` | Access denied for unauthorized role. |
| **Network Unavailable** | Client-Side Error | Dio timeout handling with in-app retry options. |

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Node.js** (v18+ recommended; v24 supported)
- **Flutter SDK** (v3.16+ / Dart 3.0+)

---

### 2. Start the Mock REST API Backend

```bash
# Navigate to the backend directory
cd backend

# Start the server (runs on port 3000 with auto-seeded database)
node server.js
```

> **Verify API**: Open `http://localhost:3000/` in your browser. You will see a `200 OK` health status.
>
> **Run automated test suite**:
> ```bash
> node backend/test_api.js
> ```

---

### 3. Run the Flutter Mobile Application

```bash
# In the root project directory:
flutter pub get

# Run on your target device or emulator
flutter run
```

#### 🌐 Network Configuration for Different Devices:
- **Android Emulator**: Uses `http://10.0.2.2:3000` (pre-configured default).
- **Windows Desktop / Web**: Uses `http://localhost:3000`.
- **Physical Device**: Tap the **Server Settings** icon (top-right of login screen) and enter your machine's local IP (e.g., `http://192.168.1.100:3000`).

---

## 👥 Demo Accounts (Pre-Seeded)

| Role | Email | Password | Purpose |
|---|---|---|---|
| **Employee** | `employee@test.com` | `123456` | General employee check-in / check-out |
| **Employee 2** | `sarah@company.com` | `123456` | Field employee |
| **Administrator** | `admin@company.com` | `admin123` | Session QR generator & dashboard metrics |

*Note: The login screen contains 1-tap "Quick Demo Fill" chips for immediate testing without typing.*

---

## 🧪 Automated Tests

Run the model and serialization unit tests:
```bash
flutter test
```
Result:
```
00:00 +0: UserModel serialization test
00:00 +1: AttendanceModel serialization test
00:00 +2: All tests passed!
```

Run static analysis check:
```bash
flutter analyze
```
Result:
```
No issues found!
```
