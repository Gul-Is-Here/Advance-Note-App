import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/theme_controller.dart';
import 'package:note_app/services/lock_service.dart';
import 'package:note_app/services/pdf_export_service.dart';
import 'package:note_app/widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeController themeController = Get.find();
  final NoteController noteController = Get.find();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom AppBar
            SliverToBoxAdapter(
              child: CustomAppBar(
                title: 'Settings',
                subtitle: 'Manage your app preferences',
                showThemeToggle: true,
                showBackButton: false,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Preferences", cs),
                    const SizedBox(height: 16),
                    _buildAnimatedCard(
                      child: Obx(
                        () => SwitchListTile(
                          activeColor: cs.primary,
                          inactiveTrackColor: cs.surfaceContainerHighest,
                          title: Text(
                            'Dark Mode',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'Toggle between light and dark theme',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              themeController.isDarkMode.value
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: cs.onPrimaryContainer,
                              size: 24,
                            ),
                          ),
                          value: themeController.isDarkMode.value,
                          onChanged: (_) => themeController.toggleTheme(),
                        ),
                      ),
                      theme: theme,
                    ),
                    const SizedBox(height: 32),

                    // Security Section
                    _buildSectionHeader("Security", cs),
                    const SizedBox(height: 16),
                    _buildSecuritySection(theme),
                    const SizedBox(height: 32),

                    _buildSectionHeader("Utilities", cs),
                    const SizedBox(height: 16),

                    // Add Shorebird Update Widget
                    // const UpdateWidget(),
                    _buildAnimatedCard(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.tertiaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.upload_file_rounded,
                            color: cs.onTertiaryContainer,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          'Export Notes',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Save notes as PDF file',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                        onTap: () => _exportNotes(context),
                      ),
                      theme: theme,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, required ThemeData theme}) {
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }

  Widget _buildSecuritySection(ThemeData theme) {
    final lockService = Get.find<LockService>();
    final cs = theme.colorScheme;

    return Column(
      children: [
        // Set/Change PIN
        _buildAnimatedCard(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    lockService.hasPinCode
                        ? cs.tertiaryContainer
                        : cs.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                lockService.hasPinCode
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                color:
                    lockService.hasPinCode
                        ? cs.onTertiaryContainer
                        : cs.onSecondaryContainer,
                size: 24,
              ),
            ),
            title: Text(
              lockService.hasPinCode ? 'Change PIN' : 'Set PIN',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            subtitle: Text(
              lockService.hasPinCode
                  ? 'Change your security PIN'
                  : 'Set a PIN to secure your notes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            onTap: () => _showSetPinDialog(theme),
          ),
          theme: theme,
        ),
        const SizedBox(height: 12),

        // Enable App Lock
        if (lockService.hasPinCode)
          _buildAnimatedCard(
            child: SwitchListTile(
              activeColor: cs.tertiary,
              inactiveTrackColor: cs.surfaceContainerHighest,
              title: Text(
                'App Lock',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Text(
                'Require authentication to open the app',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.phonelink_lock_rounded,
                  color: cs.onTertiaryContainer,
                  size: 24,
                ),
              ),
              value: lockService.isAppLocked,
              onChanged: (value) async {
                await lockService.setAppLock(value);
                Get.snackbar(
                  value ? 'Enabled' : 'Disabled',
                  value
                      ? 'App lock has been enabled'
                      : 'App lock has been disabled',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: cs.surfaceContainerHighest,
                  colorText: cs.onSurface,
                );
              },
            ),
            theme: theme,
          ),
        if (lockService.hasPinCode) const SizedBox(height: 12),
      ],
    );
  }

  void _showSetPinDialog(ThemeData theme) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final cs = theme.colorScheme;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: cs.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lock_rounded,
                color: cs.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Set Security PIN',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: 'Enter PIN (4-6 digits)',
                labelStyle: TextStyle(color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.primary, width: 2),
                ),
                prefixIcon: Icon(Icons.pin_rounded, color: cs.primary),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                labelStyle: TextStyle(color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.primary, width: 2),
                ),
                prefixIcon: Icon(Icons.check_circle_rounded, color: cs.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.close(1);
            },
            style: TextButton.styleFrom(
              foregroundColor: cs.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              final confirmPin = confirmPinController.text.trim();

              if (pin.length < 4 || pin.length > 6) {
                Get.snackbar(
                  'Error',
                  'PIN must be 4-6 digits',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: cs.errorContainer,
                  colorText: cs.onErrorContainer,
                  duration: const Duration(seconds: 2),
                );
                return;
              }

              if (pin != confirmPin) {
                Get.snackbar(
                  'Error',
                  'PINs do not match',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: cs.errorContainer,
                  colorText: cs.onErrorContainer,
                  duration: const Duration(seconds: 2),
                );
                return;
              }

              final lockService = Get.find<LockService>();
              await lockService.setPinCode(pin);
              Get.close(1);

              // Wait a bit before showing snackbar
              await Future.delayed(const Duration(milliseconds: 100));
              Get.snackbar(
                'Success',
                'PIN has been set successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: cs.primaryContainer,
                colorText: cs.onPrimaryContainer,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportNotes(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    try {
      // Check if there are notes to export
      if (noteController.notes.isEmpty) {
        // Use Flutter's built-in SnackBar instead of GetX
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_rounded, color: cs.onErrorContainer),
                const SizedBox(width: 12),
                const Expanded(child: Text('There are no notes to export.')),
              ],
            ),
            backgroundColor: cs.errorContainer,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Creating PDF...',
                  style: TextStyle(color: cs.onSurface, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      print('🎯 Starting PDF export for ${noteController.notes.length} notes');

      // Export all notes as PDF
      await PdfExportService.instance.exportMultipleNotesToPdf(
        noteController.notes,
        'All Notes Export',
      );

      print('✅ PDF export completed successfully');

      // Close loading dialog
      Get.close(1);

      // Wait a bit before showing snackbar
      await Future.delayed(const Duration(milliseconds: 300));

      // Use Flutter's built-in SnackBar for success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: cs.onPrimaryContainer),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Notes exported as PDF successfully!'),
                ),
              ],
            ),
            backgroundColor: cs.primaryContainer,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      try {
        Get.close(1);
      } catch (_) {}

      print('❌ PDF export failed: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');

      // Wait a bit and show error snackbar
      await Future.delayed(const Duration(milliseconds: 300));

      // Use Flutter's built-in SnackBar for errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: cs.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to export: ${e.toString()}')),
              ],
            ),
            backgroundColor: cs.errorContainer,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
