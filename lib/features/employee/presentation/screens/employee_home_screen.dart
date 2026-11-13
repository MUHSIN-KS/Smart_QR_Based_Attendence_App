import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../data/models/attendance_model.dart';
import '../bloc/employee_attendance_bloc.dart';
import '../bloc/employee_attendance_event.dart';
import '../bloc/employee_attendance_state.dart';
import 'qr_scanner_screen.dart';
import 'attendance_history_screen.dart';
import 'profile_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeAttendanceBloc>().add(LoadEmployeeAttendance());
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
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
    final userName = authState is Authenticated ? authState.user.name : 'Employee';
    final userDept = authState is Authenticated ? authState.user.department : 'Operations';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    userDept,
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
            tooltip: 'My Profile',
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: BlocConsumer<EmployeeAttendanceBloc, EmployeeAttendanceState>(
        listener: (context, state) {
          if (state is EmployeeAttendanceError) {
            DialogUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is EmployeeAttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          AttendanceModel? todayRecord;
          List<AttendanceModel> history = [];

          if (state is EmployeeAttendanceLoaded) {
            todayRecord = state.todayRecord;
            history = state.history;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EmployeeAttendanceBloc>().add(RefreshEmployeeAttendance());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date Header Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Today's Overview",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateTimeUtils.formatFullDate(DateTime.now()),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                DateTimeUtils.formatTime(DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Today's Status Main Card
                      _buildTodayStatusCard(context, todayRecord),
                      const SizedBox(height: 24),

                      // Quick Action Bar
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              icon: Icons.history_rounded,
                              label: 'Attendance History',
                              color: AppColors.secondary,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AttendanceHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildQuickActionButton(
                              icon: Icons.person_outline_rounded,
                              label: 'My Profile',
                              color: AppColors.primary,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Recent Attendance Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Recent Attendance Logs',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (history.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AttendanceHistoryScreen(),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (history.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.event_note_rounded, size: 48, color: AppColors.textMuted),
                              SizedBox(height: 12),
                              Text(
                                'No attendance records yet',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your scan logs will appear here after marking attendance.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: history.length > 5 ? 5 : history.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _buildAttendanceListItem(history[index]);
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

  Widget _buildTodayStatusCard(BuildContext context, AttendanceModel? record) {
    final bool isCheckedIn = record != null && record.isCheckedIn;
    final bool isCheckedOut = record != null && record.isCheckedOut;

    Color badgeBgColor;
    Color badgeTextColor;
    String badgeTitle;
    IconData badgeIcon;

    if (!isCheckedIn) {
      badgeBgColor = AppColors.warningLight;
      badgeTextColor = AppColors.warning;
      badgeTitle = 'NOT CHECKED IN';
      badgeIcon = Icons.access_time_rounded;
    } else if (!isCheckedOut) {
      badgeBgColor = AppColors.infoLight;
      badgeTextColor = AppColors.info;
      badgeTitle = record.isLate ? 'CHECKED IN (LATE)' : 'CHECKED IN (PRESENT)';
      badgeIcon = Icons.check_circle_outline_rounded;
    } else {
      badgeBgColor = AppColors.successLight;
      badgeTextColor = AppColors.success;
      badgeTitle = 'ATTENDANCE COMPLETE';
      badgeIcon = Icons.task_alt_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Attendance Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeTextColor),
                    const SizedBox(width: 6),
                    Text(
                      badgeTitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timestamps row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.login_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Check In',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record?.checkInFormatted ?? '--:--',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.logout_rounded, size: 16, color: AppColors.secondary),
                          SizedBox(width: 6),
                          Text(
                            'Check Out',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record?.checkOutFormatted ?? '--:--',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action button
          if (!isCheckedIn) ...[
            ElevatedButton.icon(
              onPressed: () => _navigateToScanner(context, isCheckOut: false),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan QR Code to Check In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ] else if (!isCheckedOut) ...[
            ElevatedButton.icon(
              onPressed: () => _navigateToScanner(context, isCheckOut: true),
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan QR Code to Check Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.successLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Work duration today: ${record.durationText}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
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

  Widget _buildAttendanceListItem(AttendanceModel item) {
    final bool isLate = item.isLate;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLate ? AppColors.warningLight : AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isLate ? Icons.timer_outlined : Icons.check_circle_outline_rounded,
              color: isLate ? AppColors.warning : AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.dateFormatted,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'In: ${item.checkInFormatted} • Out: ${item.checkOutFormatted}',
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
              item.status.toUpperCase(),
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
  }

  void _navigateToScanner(BuildContext context, {required bool isCheckOut}) {
    final bloc = context.read<EmployeeAttendanceBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(isCheckOut: isCheckOut),
      ),
    ).then((_) {
      if (mounted) {
        bloc.add(RefreshEmployeeAttendance());
      }
    });
  }
}
