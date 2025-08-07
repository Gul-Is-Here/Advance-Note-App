import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/views/create_view.dart';
import 'package:note_app/widgets/category_chips.dart';

import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  String _getPlainText() {
    try {
      final document = Document.fromJson(jsonDecode(note.content));
      return document.toPlainText().trim();
    } catch (e) {
      return note.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<NoteController>();
    final textContent = _getPlainText();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap:
            () => Get.to(
              () => CreateNoteView(note: note),
              transition: Transition.cupertino,
              duration: const Duration(milliseconds: 400),
            ),
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background card with subtle gradient
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: note.isPinned ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient:
                    note.isPinned
                        ? LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.08),
                            colorScheme.secondary.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                border: Border.all(
                  color:
                      note.isPinned
                          ? colorScheme.primary.withOpacity(0.3)
                          : colorScheme.surfaceVariant,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with pin indicator
                    Row(
                      children: [
                        if (note.isPinned)
                          Icon(
                            Icons.push_pin,
                            size: 18,
                            color: colorScheme.secondary,
                          ),
                        if (note.isPinned) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? 'Untitled' : note.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Content preview
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          textContent.isEmpty ? 'No content' : textContent,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Footer with category and date
                    Row(
                      children: [
                        CategoryChip(category: note.category),
                        const Spacer(),
                        Text(
                          DateFormat('MMM dd, yyyy').format(note.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Favorite and pin buttons in top-right corner
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                children: [
                  // Favorite button
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => controller.toggleFavorite(note.id!),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            note.isFavorite
                                ? colorScheme.secondary.withOpacity(0.2)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        note.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 20,
                        color:
                            note.isFavorite
                                ? colorScheme.secondary
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Pin button
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => controller.togglePin(note.id!),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            note.isPinned
                                ? colorScheme.primary.withOpacity(0.2)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        note.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 20,
                        color:
                            note.isPinned
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Subtle corner accent for pinned notes
            if (note.isPinned)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.push_pin_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
