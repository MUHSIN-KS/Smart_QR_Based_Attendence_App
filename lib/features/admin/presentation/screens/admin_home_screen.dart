import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../data/models/admin_dashboard_model.dart';
import '../../data/models/employee_model.dart';
import '../bloc/admin_dashboard_bloc.dart';
import '../bloc/admin_dashboard_event.dart';
import '../bloc/admin_dashboard_state.dart';
import 'admin_qr_generator_screen.dart';
import 'admin_attendance_list_screen.dart';
import 'admin_employee_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardBloc>().add(LoadAdminDashboard());
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to exit Admin Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final adminName = authState is Authenticated ? authState.user.name : 'Administrator';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4338CA).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF4338CA), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    adminName,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.textSecondary),
            onPressed: () {
              final apiClient = context.read<ApiClient>();
              DialogUtils.showServerSettingsDialog(context, apiClient);
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
        listener: (context, state) {
          if (state is AdminDashboardError) {
            DialogUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          AdminDashboardModel? dashboard;
          List<AdminAttendanceRecord> recentRecords = [];

          if (state is AdminDashboardLoaded) {
            dashboard = state.dashboard;
            recentRecords = state.recentRecords;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(RefreshAdminDashboard());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Active Session Quick Card
                      _buildActiveSessionBanner(context, dashboard?.activeSession),
                      const SizedBox(height: 20),

                      // Metrics Grid (Total, Present, Absent, Late)
                      const Text(
                        "Today's Statistics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Employees',
                              value: '${dashboard?.totalEmployees ?? 0}',
                              icon: Icons.groups_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Present Today',
                              value: '${dashboard?.present ?? 0}',
                              icon: Icons.check_circle_rounded,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Absent / Pending',
                              value: '${dashboard?.absent ?? 0}',
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Late Arrivals',
                              value: '${dashboard?.late ?? 0}',
                              icon: Icons.access_time_filled_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Navigation Actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildNavigationButton(
                              icon: Icons.qr_code_2_rounded,
                              title: 'Generate QR Code',
                              subtitle: 'Create dynamic time-limited session',
                              gradient: AppColors.adminGradient,
                              onTap: () {
                                final bloc = context.read<AdminDashboardBloc>();
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminQrGeneratorScreen()),
                                ).then((_) {
                                  if (mounted) {
                                    bloc.add(RefreshAdminDashboard());
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSecondaryTile(
                              icon: Icons.table_view_rounded,
                              label: 'Attendance Records',
                              color: AppColors.secondary,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminAttendanceListScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSecondaryTile(
                              icon: Icons.people_outline_rounded,
                              label: 'Employee Directory',
                              color: AppColors.primary,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminEmployeeListScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Recent Activity Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Live Attendance Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (recentRecords.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AdminAttendanceListScreen()),
                                );
                              },
                              child: const Text('View All'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (recentRecords.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.inbox_rounded, size: 44, color: AppColors.textMuted),
                              SizedBox(height: 10),
                              Text(
                                'No attendance recorded yet today',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentRecords.length > 5 ? 5 : recentRecords.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final r = recentRecords[index];
                            final isLate = r.isLate;

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF4338CA).withValues(alpha: 0.1),
                                    child: Text(
                                      r.employeeName.isNotEmpty ? r.employeeName[0].toUpperCase() : 'E',
                                      style: const TextStyle(
                                        color: Color(0xFF4338CA),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.employeeName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          '${r.department} • In: ${r.checkInFormatted}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLate ? AppColors.warningLight : AppColors.successLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      r.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isLate ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveSessionBanner(BuildContext context, ActiveSessionModel? session) {
    final bool hasActiveSession = session != null && !session.isExpired;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: hasActiveSession ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasActiveSession ? const Color(0xFF6366F1).withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasActiveSession ? const Color(0xFF4338CA) : AppColors.textMuted.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              color: hasActiveSession ? Colors.white : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: hasActiveSession ? AppColors.success : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        hasActiveSession ? 'ACTIVE QR SESSION' : 'NO ACTIVE SESSION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: hasActiveSession ? const Color(0xFF4338CA) : AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  hasActiveSession
                      ? 'Token: ${session.qrToken}'
                      : 'Generate session to scan QR',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            onPressed: () {
              final bloc = context.read<AdminDashboardBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminQrGeneratorScreen()),
              ).then((_) {
                if (mounted) {
                  bloc.add(RefreshAdminDashboard());
                }
              });
            },
            child: Text(
              hasActiveSession ? 'View QR' : 'Create',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
