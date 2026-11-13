import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminAttendanceListScreen extends StatefulWidget {
  const AdminAttendanceListScreen({super.key});

  @override
  State<AdminAttendanceListScreen> createState() => _AdminAttendanceListScreenState();
}

class _AdminAttendanceListScreenState extends State<AdminAttendanceListScreen> {
  List<AdminAttendanceRecord> _records = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final list = await repo.getAttendanceRecords();
      if (mounted) {
        setState(() {
          _records = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        DialogUtils.showErrorSnackBar(context, 'Failed to load attendance records: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _records.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.employeeName.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q) ||
          r.date.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Records'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchRecords,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by employee, department or date...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // Main list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRecords,
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty ? 'No matches found' : 'No attendance logs yet',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildAttendanceCard(filtered[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AdminAttendanceRecord r) {
    final bool isLate = r.isLate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Employee Name + Status Pill
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF4338CA).withValues(alpha: 0.12),
                child: Text(
                  r.employeeName.isNotEmpty ? r.employeeName[0].toUpperCase() : 'E',
                  style: const TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.employeeName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${r.department} • ${r.employeeEmail}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLate ? AppColors.warningLight : AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
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
          const Divider(height: 20),

          // Timestamps row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      DateTimeUtils.formatIsoDateString(r.date),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Check In', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      r.checkInFormatted,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                      r.checkOutFormatted,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Worked', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      r.durationText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // GPS Coordinates footer
          if (r.latitudeIn != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'GPS: ${r.latitudeIn!.toStringAsFixed(4)}, ${r.longitudeIn?.toStringAsFixed(4) ?? ""}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sess: ${r.sessionId.length > 12 ? r.sessionId.substring(0, 12) : r.sessionId}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
