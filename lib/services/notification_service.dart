import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxBool _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await initialize();
  }

  // 🚀 Initialize notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Karachi')); // Set your timezone

      // Android initialization
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      _isInitialized.value = true;
      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  // 📱 Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      // Android 13+ requires explicit permission
      final androidPlugin =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // iOS permissions
      final iosPlugin =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // 🔔 Schedule reminder for a note
  Future<bool> scheduleReminder({
    required int noteId,
    required String noteTitle,
    required DateTime reminderDate,
    String? noteContent,
  }) async {
    try {
      if (!_isInitialized.value) {
        Get.snackbar('Error', 'Notification service not initialized');
        return false;
      }

      // Check if date is in the future
      if (reminderDate.isBefore(DateTime.now())) {
        Get.snackbar('Error', 'Reminder date must be in the future');
        return false;
      }

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        reminderDate,
        tz.local,
      );

      await _notificationsPlugin.zonedSchedule(
        noteId, // Use note ID as notification ID
        '📌 Reminder: $noteTitle',
        noteContent?.isNotEmpty == true
            ? noteContent!.substring(
              0,
              noteContent.length > 100 ? 100 : noteContent.length,
            )
            : 'Tap to view note',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'note_reminders',
            'Note Reminders',
            channelDescription: 'Reminders for your notes',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              noteContent ?? '',
              contentTitle: noteTitle,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: noteContent?.substring(
              0,
              noteContent.length > 50 ? 50 : noteContent.length,
            ),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'note_$noteId', // Pass note ID for navigation
      );

      print('✅ Reminder scheduled for: $scheduledDate');
      Get.snackbar(
        'Success',
        'Reminder set for ${_formatDate(reminderDate)}',
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
      Get.snackbar('Error', 'Failed to schedule reminder');
      return false;
    }
  }

  // ❌ Cancel reminder for a note
  Future<void> cancelReminder(int noteId) async {
    try {
      await _notificationsPlugin.cancel(noteId);
      print('✅ Reminder cancelled for note $noteId');
      Get.snackbar('Success', 'Reminder cancelled');
    } catch (e) {
      print('❌ Error cancelling reminder: $e');
    }
  }

  // 🗑️ Cancel all reminders
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('✅ All reminders cancelled');
    } catch (e) {
      print('❌ Error cancelling all reminders: $e');
    }
  }

  // 📋 Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      return pending;
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  // 🔔 Show instant notification
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'instant_notifications',
            'Instant Notifications',
            channelDescription: 'Quick notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  // 📌 When notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.startsWith('note_')) {
      final noteId = int.tryParse(payload.replaceFirst('note_', ''));
      if (noteId != null) {
        // Navigate to note (implement in controller)
        print('📌 Opening note: $noteId');
        // Get.toNamed('/note', arguments: noteId);
      }
    }
  }

  // 📅 Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  // 🧪 Test notification
  Future<void> testNotification() async {
    await showInstantNotification(
      id: 999,
      title: '🎉 Test Notification',
      body: 'Notifications are working perfectly!',
    );
  }
}
