import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_screen.dart';
import '../../../employee/presentation/screens/employee_home_screen.dart';
import '../../../admin/presentation/screens/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: AppConstants.demoEmployeeEmail);
  final _passwordController = TextEditingController(text: AppConstants.demoEmployeePassword);
  bool _obscurePassword = true;
  bool _isAdminSelected = false;
  bool _showConnectionBanner = false;

  @override
  void initState() {
    super.initState();
    // On physical Android with no saved server URL, auto-open settings dialog
    // so the user knows they need to enter their LAN IP.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final apiClient = context.read<ApiClient>();
      if (apiClient.needsServerConfig) {
        DialogUtils.showServerSettingsDialog(context, apiClient, autoFocused: true);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(bool isAdmin) {
    setState(() {
      _isAdminSelected = isAdmin;
      if (isAdmin) {
        _emailController.text = AppConstants.demoAdminEmail;
        _passwordController.text = AppConstants.demoAdminPassword;
      } else {
        _emailController.text = AppConstants.demoEmployeeEmail;
        _passwordController.text = AppConstants.demoEmployeePassword;
      }
    });
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          setState(() => _showConnectionBanner = false);
          DialogUtils.showSuccessSnackBar(
            context,
            'Welcome back, ${state.user.name}!',
          );
          if (state.user.isAdmin) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
            );
          }
        } else if (state is AuthError) {
          if (state.isConnectionError) {
            setState(() => _showConnectionBanner = true);
          } else {
            setState(() => _showConnectionBanner = false);
            DialogUtils.showErrorSnackBar(context, state.message);
          }
        } else if (state is AuthLoading) {
          setState(() => _showConnectionBanner = false);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: 'Server Settings',
                icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.textSecondary),
                onPressed: () {
                  final apiClient = context.read<ApiClient>();
                  DialogUtils.showServerSettingsDialog(context, apiClient);
                },
              ),
            ],
          ),
          // ── body: Column with optional connection banner ────────────────
          body: Column(
            children: [
              // ── Persistent red banner shown when server can't be reached ─
              if (_showConnectionBanner)
                Container(
                  width: double.infinity,
                  color: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Cannot reach server. Set your backend IP.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          backgroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final apiClient = context.read<ApiClient>();
                          DialogUtils.showServerSettingsDialog(
                            context,
                            apiClient,
                            autoFocused: true,
                          );
                        },
                        child: const Text(
                          'Fix',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Main scrollable content ──────────────────────────────────
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── App Logo & Header ───────────────────────
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: _isAdminSelected
                                        ? AppColors.adminGradient
                                        : AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isAdminSelected
                                                ? const Color(0xFF4338CA)
                                                : AppColors.primary)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isAdminSelected
                                        ? Icons.admin_panel_settings_rounded
                                        : Icons.qr_code_scanner_rounded,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _isAdminSelected ? 'Admin Portal' : 'Employee Login',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isAdminSelected
                                    ? 'Manage sessions, live statistics & records'
                                    : 'Sign in to scan and record daily attendance',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Role Selector Toggle ────────────────────
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _onRoleChanged(false),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: !_isAdminSelected
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                size: 18,
                                                color: !_isAdminSelected
                                                    ? Colors.white
                                                    : AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Employee',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: !_isAdminSelected
                                                      ? Colors.white
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _onRoleChanged(true),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _isAdminSelected
                                                ? const Color(0xFF4338CA)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.security_rounded,
                                                size: 18,
                                                color: _isAdminSelected
                                                    ? Colors.white
                                                    : AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Administrator',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _isAdminSelected
                                                      ? Colors.white
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Form Card ───────────────────────────────
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Email Field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        labelText: 'Email Address',
                                        hintText: 'name@company.com',
                                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your email address';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),

                                    // Password Field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: '••••••',
                                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // Login Button
                                    ElevatedButton(
                                      onPressed: isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isAdminSelected
                                            ? const Color(0xFF4338CA)
                                            : AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              _isAdminSelected
                                                  ? 'Login as Admin'
                                                  : 'Login as Employee',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── Quick Demo Fill Chips ───────────────────
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Quick Demo Fill:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ActionChip(
                                        avatar: const Icon(Icons.person_outline, size: 16),
                                        label: const Text(
                                          'Justin (employee@test.com)',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () {
                                          _onRoleChanged(false);
                                          _emailController.text = 'employee@test.com';
                                          _passwordController.text = '123456';
                                        },
                                      ),
                                      ActionChip(
                                        avatar: const Icon(
                                          Icons.admin_panel_settings_outlined,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Admin (admin@company.com)',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () {
                                          _onRoleChanged(true);
                                          _emailController.text = 'admin@company.com';
                                          _passwordController.text = 'admin123';
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // ── Register Link ────────────────────────────
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Register Now',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
