import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/attendance_model.dart';
import '../bloc/employee_attendance_bloc.dart';
import '../bloc/employee_attendance_event.dart';
import '../bloc/employee_attendance_state.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Attendance History'),
      ),
      body: BlocBuilder<EmployeeAttendanceBloc, EmployeeAttendanceState>(
        builder: (context, state) {
          if (state is EmployeeAttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<AttendanceModel> history = [];
          if (state is EmployeeAttendanceLoaded) {
            history = state.history;
          }

          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy_rounded, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text(
                      'No Attendance Records',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your attendance logs will appear here once you scan attendance QR codes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<EmployeeAttendanceBloc>().add(RefreshEmployeeAttendance());
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          }

          final int totalDays = history.length;
          final int onTimeCount = history.where((e) => !e.isLate).length;
          final int lateCount = history.where((e) => e.isLate).length;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EmployeeAttendanceBloc>().add(RefreshEmployeeAttendance());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Total Logs',
                        value: '$totalDays',
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'On Time',
                        value: '$onTimeCount',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Late',
                        value: '$lateCount',
                        icon: Icons.access_time_rounded,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'All Attendance Records',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),

                ...history.map((record) => _buildHistoryCard(context, record)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AttendanceModel item) {
    final bool isLate = item.isLate;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.dateFormatted,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLate ? AppColors.warningLight : AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
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
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Check In', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      item.checkInFormatted,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Check Out', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      item.checkOutFormatted,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hours Worked', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      item.durationText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.latitudeIn != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  'GPS In: ${item.latitudeIn!.toStringAsFixed(4)}, ${item.longitudeIn?.toStringAsFixed(4) ?? ""}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

