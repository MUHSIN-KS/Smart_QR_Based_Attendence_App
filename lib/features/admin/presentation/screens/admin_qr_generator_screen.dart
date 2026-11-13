import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../data/models/admin_dashboard_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../bloc/admin_qr_bloc.dart';
import '../bloc/admin_qr_event.dart';
import '../bloc/admin_qr_state.dart';

class AdminQrGeneratorScreen extends StatelessWidget {
  const AdminQrGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminQrBloc(
        context.read<AdminRepository>(),
      )..add(LoadCurrentSession()),
      child: const _AdminQrGeneratorView(),
    );
  }
}

class _AdminQrGeneratorView extends StatefulWidget {
  const _AdminQrGeneratorView();

  @override
  State<_AdminQrGeneratorView> createState() => _AdminQrGeneratorViewState();
}

class _AdminQrGeneratorViewState extends State<_AdminQrGeneratorView> {
  int _selectedValidityMinutes = 2;

  String _formatTimer(int seconds) {
    if (seconds <= 0) return '00:00';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Attendance QR'),
        actions: [
          IconButton(
            tooltip: 'Refresh Session',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AdminQrBloc>().add(LoadCurrentSession());
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminQrBloc, AdminQrState>(
        listener: (context, state) {
          if (state is AdminQrError) {
            DialogUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Validity selector card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.timer_outlined, color: Color(0xFF4338CA), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Session Validity Duration',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [1, 2, 5, 10].map((mins) {
                              final isSelected = _selectedValidityMinutes == mins;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ChoiceChip(
                                    label: Text('$mins min'),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFF4338CA),
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    onSelected: (val) {
                                      if (val) {
                                        setState(() => _selectedValidityMinutes = mins);
                                      }
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4338CA),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: state is AdminQrLoading
                                  ? null
                                  : () {
                                      context.read<AdminQrBloc>().add(
                                            GenerateNewSession(
                                              validityMinutes: _selectedValidityMinutes,
                                            ),
                                          );
                                    },
                              icon: const Icon(Icons.bolt_rounded),
                              label: Text(
                                state is AdminQrActive
                                    ? 'Generate New Session QR'
                                    : 'Start Attendance Session',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // QR Display Card
                    if (state is AdminQrLoading)
                      Container(
                        height: 380,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                              ),
                              SizedBox(height: 16),
                              Text('Creating secure QR session...', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else if (state is AdminQrActive)
                      _buildQrDisplayCard(context, state.session, state.currentRemainingSeconds)
                    else
                      Container(
                        padding: const EdgeInsets.all(36),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4338CA).withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                size: 64,
                                color: Color(0xFF4338CA),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Active Session',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Click "Start Attendance Session" above to generate a live, time-limited QR code for employees to scan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrDisplayCard(
    BuildContext context,
    ActiveSessionModel session,
    int remainingSeconds,
  ) {
    final bool isExpired = remainingSeconds <= 0;
    final totalSeconds = session.validityMinutes * 60;
    final progress = totalSeconds > 0 ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isExpired ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFF6366F1).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Live Countdown Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isExpired ? AppColors.errorLight : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isExpired ? Icons.alarm_off_rounded : Icons.access_time_filled_rounded,
                        color: isExpired ? AppColors.error : const Color(0xFF4338CA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isExpired ? 'SESSION EXPIRED' : 'EXPIRES IN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isExpired ? AppColors.error : const Color(0xFF4338CA),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimer(remainingSeconds),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isExpired ? AppColors.error : const Color(0xFF4338CA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Linear countdown progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                isExpired ? AppColors.error : (progress < 0.2 ? AppColors.warning : const Color(0xFF4338CA)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // QR Code Graphic
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: QrImageView(
                  data: session.qrToken,
                  version: QrVersions.auto,
                  size: 230.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1E1B4B),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
              ),

              // Expired Overlay
              if (isExpired)
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.block_rounded, color: AppColors.error, size: 54),
                      const SizedBox(height: 12),
                      const Text(
                        'QR Token Expired',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Generate a new session above',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4338CA),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          context.read<AdminQrBloc>().add(
                                GenerateNewSession(
                                  validityMinutes: _selectedValidityMinutes,
                                ),
                              );
                        },
                        child: const Text('Regenerate Now'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Token pill with 1-click copy for testing
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('QR Token String:', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text(
                        session.qrToken,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy Token',
                  icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF4338CA)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: session.qrToken));
                    DialogUtils.showSuccessSnackBar(context, 'Copied ${session.qrToken} to clipboard');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Session ID: ${session.sessionId} • Valid for ${session.validityMinutes} mins',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
