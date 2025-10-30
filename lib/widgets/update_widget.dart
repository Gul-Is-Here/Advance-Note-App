import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/services/shorebird_service.dart';

class UpdateWidget extends StatelessWidget {
  const UpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final shorebirdService = ShorebirdService.instance;

    return Obx(() {
      // If there's no update, don't show anything
      if (!shorebirdService.isUpdateAvailable &&
          !shorebirdService.isUpdating &&
          shorebirdService.updateStatus.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              shorebirdService.isUpdating
                  ? Icons.download
                  : Icons.system_update,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shorebirdService.isUpdating
                        ? 'Updating...'
                        : 'Update Available!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (shorebirdService.updateStatus.isNotEmpty)
                    Text(
                      shorebirdService.updateStatus,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                ],
              ),
            ),

            // Loading or action button
            if (shorebirdService.isUpdating)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (shorebirdService.isUpdateAvailable)
              ElevatedButton(
                onPressed: () => shorebirdService.downloadUpdate(),
                child: const Text('Update'),
              ),
          ],
        ),
      );
    });
  }
}
