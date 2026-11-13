import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../employee/presentation/screens/employee_home_screen.dart';
import '../../../admin/presentation/screens/admin_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController(text: 'Operations');
  String _selectedRole = 'employee';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
              department: _departmentController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          DialogUtils.showSuccessSnackBar(context, 'Account created successfully!');
          if (state.user.isAdmin) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
              (route) => false,
            );
          }
        } else if (state is AuthError) {
          DialogUtils.showErrorSnackBar(context, state.message);
          if (state.isConnectionError) {
            final apiClient = context.read<ApiClient>();
            DialogUtils.showServerSettingsDialog(context, apiClient, autoFocused: true);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Create Account'),
            actions: [
              IconButton(
                tooltip: 'Server Connection Settings',
                icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.textSecondary),
                onPressed: () {
                  final apiClient = context.read<ApiClient>();
                  DialogUtils.showServerSettingsDialog(context, apiClient);
                },
              ),
            ],
          ),
          body: SafeArea(
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
                        const Text(
                          'Join Smart QR Attendance',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your employee details to register your account.',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  hintText: 'e.g. John Doe',
                                  prefixIcon: Icon(Icons.person_outline, size: 20),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Work Email',
                                  hintText: 'name@company.com',
                                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: 'At least 6 characters',
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
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _departmentController,
                                decoration: const InputDecoration(
                                  labelText: 'Department',
                                  hintText: 'e.g. Operations, Drilling, IT',
                                  prefixIcon: Icon(Icons.business_outlined, size: 20),
                                ),
                              ),
                              const SizedBox(height: 16),

                              DropdownButtonFormField<String>(
                                initialValue: _selectedRole,
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'employee',
                                    child: Text('Employee'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'admin',
                                    child: Text('Administrator'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedRole = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              ElevatedButton(
                                onPressed: isLoading ? null : _handleRegister,
                                style: ElevatedButton.styleFrom(
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
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already registered?',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
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
        );
      },
    );
  }
}

