class AppConstants {
  static const String appName = 'Smart QR Attendance';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyBaseUrl = 'custom_base_url';
  static const String keyLastRole = 'last_login_role';

  // Default Backend URLs
  // 10.0.2.2 is the special alias for host localhost in Android Emulator
  // localhost works for Windows desktop, iOS simulator, and Chrome web
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String defaultLocalhostUrl = 'http://localhost:3000';
  static const String defaultLanUrl = 'http://192.168.0.165:3000';

  // Demo Credentials for fast evaluation
  static const String demoEmployeeEmail = 'employee@test.com';
  static const String demoEmployeePassword = '123456';
  static const String demoAdminEmail = 'admin@company.com';
  static const String demoAdminPassword = 'admin123';
}

