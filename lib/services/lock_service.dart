import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LockService extends GetxService {
  static LockService get instance => Get.find<LockService>();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Observable state
  final RxBool _isAppLocked = false.obs;
  final RxBool _hasPinCode = false.obs;
  final RxSet<int> _unlockedNotes =
      <int>{}.obs; // Track unlocked notes in session

  // Getters
  bool get isAppLocked => _isAppLocked.value;
  bool get hasPinCode => _hasPinCode.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLockSettings();
  }

  // 🔐 Load lock settings from secure storage
  Future<void> _loadLockSettings() async {
    try {
      final pinCode = await _secureStorage.read(key: 'app_pin');
      _hasPinCode.value = pinCode != null && pinCode.isNotEmpty;

      final appLocked = await _secureStorage.read(key: 'app_locked');
      _isAppLocked.value = appLocked == 'true';
    } catch (e) {
      print('Error loading lock settings: $e');
    }
  }

  // 🔒 Set app lock status
  Future<void> setAppLock(bool enabled) async {
    try {
      await _secureStorage.write(key: 'app_locked', value: enabled.toString());
      _isAppLocked.value = enabled;
    } catch (e) {
      print('Error setting app lock: $e');
    }
  }

  // 🔢 Set PIN code
  Future<bool> setPinCode(String pin) async {
    try {
      if (pin.length < 4) {
        Get.snackbar('Error', 'PIN must be at least 4 digits');
        return false;
      }

      await _secureStorage.write(key: 'app_pin', value: pin);
      _hasPinCode.value = true;
      Get.snackbar('Success', 'PIN code set successfully');
      return true;
    } catch (e) {
      print('Error setting PIN: $e');
      Get.snackbar('Error', 'Failed to set PIN code');
      return false;
    }
  }

  // 🗑️ Remove PIN code
  Future<void> removePinCode() async {
    try {
      await _secureStorage.delete(key: 'app_pin');
      _hasPinCode.value = false;
      await setAppLock(false); // Disable app lock if PIN removed
      Get.snackbar('Success', 'PIN code removed');
    } catch (e) {
      print('Error removing PIN: $e');
    }
  }

  // 🔐 Verify PIN code
  Future<bool> verifyPinCode(String enteredPin) async {
    try {
      final savedPin = await _secureStorage.read(key: 'app_pin');
      return savedPin == enteredPin;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  //  Unlock note (for session)
  void unlockNoteInSession(int noteId) {
    _unlockedNotes.add(noteId);
  }

  // 🔒 Lock note (clear from session)
  void lockNoteInSession(int noteId) {
    _unlockedNotes.remove(noteId);
  }

  // ✅ Check if note is unlocked in current session
  bool isNoteUnlockedInSession(int noteId) {
    return _unlockedNotes.contains(noteId);
  }

  // 🔄 Clear all unlocked notes (on app background/close)
  void clearUnlockedNotes() {
    _unlockedNotes.clear();
  }

  // 🔐 Authenticate to unlock note (PIN only)
  Future<bool> authenticateToUnlockNote({
    required int noteId,
    String? customReason,
  }) async {
    // Check if already unlocked in session
    if (isNoteUnlockedInSession(noteId)) {
      return true;
    }

    // Show PIN dialog
    if (_hasPinCode.value) {
      return await _showPinDialog(noteId);
    }

    Get.snackbar('Error', 'No PIN set. Please set a PIN in Settings.');
    return false;
  }

  // 🔢 Show PIN dialog
  Future<bool> _showPinDialog(int noteId) async {
    final TextEditingController pinController = TextEditingController();
    bool authenticated = false;

    await Get.dialog(
      AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'Enter your PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (Get.isDialogOpen == true) {
                Navigator.of(Get.overlayContext!).pop(false);
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final isValid = await verifyPinCode(pinController.text);
              if (isValid) {
                authenticated = true;
                unlockNoteInSession(noteId);
                if (Get.isDialogOpen == true) {
                  Navigator.of(Get.overlayContext!).pop(true);
                }
                Get.snackbar('Success', 'Note unlocked');
              } else {
                Get.snackbar('Error', 'Incorrect PIN');
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return authenticated;
  }

  // 🔐 App-level authentication (on app launch, PIN only)
  Future<bool> authenticateApp() async {
    if (!_isAppLocked.value) return true;

    // Show PIN dialog
    if (_hasPinCode.value) {
      final TextEditingController pinController = TextEditingController();
      bool authenticated = false;

      await Get.dialog(
        AlertDialog(
          title: const Text('🔒 App Locked'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter PIN to unlock the app'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter PIN',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final isValid = await verifyPinCode(pinController.text);
                if (isValid) {
                  authenticated = true;
                  if (Get.isDialogOpen == true) {
                    Navigator.of(Get.overlayContext!).pop(true);
                  }
                } else {
                  Get.snackbar('Error', 'Incorrect PIN');
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      return authenticated;
    }

    return false;
  }

  // 🧹 Cleanup
  @override
  void onClose() {
    clearUnlockedNotes();
    super.onClose();
  }
}
