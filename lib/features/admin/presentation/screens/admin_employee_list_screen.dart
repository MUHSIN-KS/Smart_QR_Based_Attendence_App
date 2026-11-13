import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/admin_repository.dart';

class AdminEmployeeListScreen extends StatefulWidget {
  const AdminEmployeeListScreen({super.key});

  @override
  State<AdminEmployeeListScreen> createState() => _AdminEmployeeListScreenState();
}

class _AdminEmployeeListScreenState extends State<AdminEmployeeListScreen> {
  List<EmployeeModel> _employees = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final list = await repo.getEmployees();
      if (mounted) {
        setState(() {
          _employees = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        DialogUtils.showErrorSnackBar(context, 'Failed to load employees: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _employees.where((e) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return e.name.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          e.department.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Employee Directory'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchEmployees,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by employee or department...',
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchEmployees,
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline_rounded, size: 54, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty ? 'No employees matching query' : 'No employees found',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final emp = filtered[index];

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      child: Text(
                                        emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  emp.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (emp.createdAt != null) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  DateTimeUtils.formatShortDate(DateTime.tryParse(emp.createdAt!) ?? DateTime.now()),
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            emp.email,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.background,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  emp.department,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'ID: #EMP-00${emp.id}',
                                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
