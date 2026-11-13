import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/services/location_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/data/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/employee/data/repositories/attendance_repository.dart';
import 'features/employee/presentation/bloc/employee_attendance_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage
  final storageService = await StorageService.init();

  // Initialize Network and Hardware Services
  final apiClient = ApiClient(storageService);
  final locationService = LocationService();

  // Initialize Repositories
  final authRepository = AuthRepository(apiClient, storageService);
  final attendanceRepository = AttendanceRepository(apiClient);
  final adminRepository = AdminRepository(apiClient);

  runApp(
    SmartQrAttendanceApp(
      storageService: storageService,
      apiClient: apiClient,
      locationService: locationService,
      authRepository: authRepository,
      attendanceRepository: attendanceRepository,
      adminRepository: adminRepository,
    ),
  );
}

class SmartQrAttendanceApp extends StatelessWidget {
  final StorageService storageService;
  final ApiClient apiClient;
  final LocationService locationService;
  final AuthRepository authRepository;
  final AttendanceRepository attendanceRepository;
  final AdminRepository adminRepository;

  const SmartQrAttendanceApp({
    super.key,
    required this.storageService,
    required this.apiClient,
    required this.locationService,
    required this.authRepository,
    required this.attendanceRepository,
    required this.adminRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<LocationService>.value(value: locationService),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<AttendanceRepository>.value(value: attendanceRepository),
        RepositoryProvider<AdminRepository>.value(value: adminRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository),
          ),
          BlocProvider<EmployeeAttendanceBloc>(
            create: (context) => EmployeeAttendanceBloc(attendanceRepository),
          ),
          BlocProvider<AdminDashboardBloc>(
            create: (context) => AdminDashboardBloc(adminRepository),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
