import 'package:get/get.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdService extends GetxService {
  static ShorebirdService get instance => Get.find<ShorebirdService>();

  final ShorebirdCodePush _shorebirdCodePush = ShorebirdCodePush();

  // Observable to track if an update is available
  final RxBool _isUpdateAvailable = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxString _updateStatus = ''.obs;

  // Getters (like asking "Is there an update?")
  bool get isUpdateAvailable => _isUpdateAvailable.value;
  bool get isUpdating => _isUpdating.value;
  String get updateStatus => _updateStatus.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _checkForUpdates();
  }

  // Check if there's a new update available (like checking your mailbox)
  Future<void> _checkForUpdates() async {
    try {
      _updateStatus.value = 'Checking for updates...';

      final isAvailable =
          await _shorebirdCodePush.isNewPatchAvailableForDownload();
      _isUpdateAvailable.value = isAvailable;

      if (isAvailable) {
        print('🎉 New update available!');
        _updateStatus.value = 'Update available!';
        // Automatically download the update
        await downloadUpdate();
      } else {
        print('✅ App is up to date!');
        _updateStatus.value = 'App is up to date';
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
      _updateStatus.value = 'Error checking updates';
    }
  }

  // Download the update (like downloading a game update)
  Future<void> downloadUpdate() async {
    try {
      _isUpdating.value = true;
      _updateStatus.value = 'Downloading update...';

      print('📥 Downloading update...');
      await _shorebirdCodePush.downloadUpdateIfAvailable();

      _updateStatus.value = 'Update downloaded! Restart app to apply.';
      print('✅ Update downloaded successfully!');

      // Show a friendly message to the user
      Get.snackbar(
        'Update Downloaded! 🎉',
        'Restart the app to see new features!',
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('❌ Error downloading update: $e');
      _updateStatus.value = 'Error downloading update';
      Get.snackbar(
        'Update Error 😢',
        'Could not download update. Please try again later.',
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  // Check for updates manually (when user taps "Check for updates")
  Future<void> checkForUpdatesManually() async {
    _updateStatus.value = 'Checking...';
    await _checkForUpdates();
  }

  // Get the current patch number (like version number)
  Future<int?> getCurrentPatch() async {
    try {
      return await _shorebirdCodePush.currentPatchNumber();
    } catch (e) {
      print('❌ Error getting current patch: $e');
      return null;
    }
  }

  // Check if app was updated using Shorebird
  Future<bool> isShorebirdAvailable() async {
    return await _shorebirdCodePush.isShorebirdAvailable();
  }
}
