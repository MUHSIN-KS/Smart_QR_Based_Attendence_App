import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../network/api_client.dart';

class DialogUtils {
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static Future<void> showServerSettingsDialog(
    BuildContext context,
    ApiClient apiClient, {
    bool autoFocused = false,
  }) async {
    final controller = TextEditingController(text: apiClient.currentBaseUrl);

    await showDialog(
      context: context,
      barrierDismissible: !autoFocused, // force action when auto-opened
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.dns_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Server Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info box ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF856404)),
                          SizedBox(width: 6),
                          Text(
                            'Physical Device Setup',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF856404),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '1. Make sure your PC and phone are on the same Wi-Fi.\n'
                        '2. On Windows, open Command Prompt and run:\n'
                        '       ipconfig\n'
                        '   Look for "IPv4 Address" under Wi-Fi adapter.\n'
                        '3. Enter that IP below (e.g. http://192.168.1.100:3000).\n'
                        '4. Run the backend:  node backend/server.js',
                        style: TextStyle(fontSize: 12, color: Color(0xFF856404), height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── URL Input ─────────────────────────────────────────────
                TextField(
                  controller: controller,
                  autofocus: autoFocused,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Backend Base URL',
                    hintText: 'http://192.168.x.x:3000',
                    prefixIcon: Icon(Icons.link_rounded),
                    helperText: 'No trailing slash. Port 3000 by default.',
                  ),
                ),
                const SizedBox(height: 12),

                // ── Quick-fill chips ──────────────────────────────────────
                const Text(
                  'Quick fill:',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.wifi, size: 14),
                      label: const Text('192.168.0.165:3000 (Current PC)', style: TextStyle(fontSize: 11)),
                      onPressed: () => controller.text = 'http://192.168.0.165:3000',
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.computer, size: 14),
                      label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                      onPressed: () => controller.text = 'http://10.0.2.2:3000',
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.laptop, size: 14),
                      label: const Text('Localhost', style: TextStyle(fontSize: 11)),
                      onPressed: () => controller.text = 'http://localhost:3000',
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            if (!autoFocused)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save & Connect'),
              onPressed: () async {
                final url = controller.text.trim();
                if (url.isNotEmpty) {
                  await apiClient.updateBaseUrl(url);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    showSuccessSnackBar(context, 'Server URL saved: $url');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

