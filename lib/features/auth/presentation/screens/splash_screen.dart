import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';
import '../../../employee/presentation/screens/employee_home_screen.dart';
import '../../../admin/presentation/screens/admin_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          if (state is Authenticated) {
            if (state.user.isAdmin) {
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
              );
            } else {
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
              );
            }
          } else if (state is Unauthenticated) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Smart QR-Based Attendance Management',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
