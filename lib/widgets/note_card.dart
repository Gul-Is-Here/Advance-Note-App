import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/views/create_view.dart';

import '../models/note_model.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _hovered = false;
  bool _pressed = false;

  String _getPlainText() {
    try {
      final document = Document.fromJson(jsonDecode(widget.note.content));
      return document.toPlainText().trim();
    } catch (_) {
      return widget.note.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final controller = Get.find<NoteController>();
    final textContent = _getPlainText();
    final pinned = widget.note.isPinned;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap:
              () => Get.to(
                () => CreateNoteView(note: widget.note),
                transition: Transition.cupertino,
                duration: const Duration(milliseconds: 400),
              ),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : (_hovered ? 1.02 : 1.0),
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                border: Border.all(
                  color:
                      pinned
                          ? cs.primary.withOpacity(0.3)
                          : (_hovered
                              ? cs.primary.withOpacity(0.2)
                              : Colors.grey.shade200),
                  width: pinned ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        pinned
                            ? cs.primary.withOpacity(0.15)
                            : Colors.black.withOpacity(_hovered ? 0.12 : 0.06),
                    blurRadius: _hovered ? 20 : 12,
                    offset: Offset(0, _hovered ? 8 : 4),
                    spreadRadius: _hovered ? 2 : 0,
                  ),
                  if (pinned)
                    BoxShadow(
                      color: cs.primary.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Subtle background pattern for pinned notes
                    if (pinned)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cs.primary.withOpacity(0.02),
                                cs.primary.withOpacity(0.08),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row with better spacing
                          Row(
                            children: [
                              if (pinned) ...[
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.push_pin_rounded,
                                    size: 16,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: Text(
                                  widget.note.title.isEmpty
                                      ? 'Untitled Note'
                                      : widget.note.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Content preview with better styling
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                textContent.isEmpty
                                    ? 'Tap to add content...'
                                    : textContent,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      textContent.isEmpty
                                          ? cs.onSurfaceVariant.withOpacity(0.6)
                                          : cs.onSurfaceVariant,
                                  height: 1.6,
                                  fontStyle:
                                      textContent.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Enhanced footer
                          Row(
                            children: [
                              // Category chip with improved design
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cs.primary.withOpacity(0.8),
                                      cs.primary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.note.category,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Enhanced date display
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: cs.onSurfaceVariant.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat(
                                        'MMM dd',
                                      ).format(widget.note.updatedAt),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withOpacity(0.8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Enhanced top-right action buttons
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _ModernActionButton(
                            active: widget.note.isFavorite,
                            activeColor: Colors.red.shade400,
                            icon:
                                widget.note.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                            onTap:
                                () =>
                                    controller.toggleFavorite(widget.note.id!),
                          ),
                          const SizedBox(width: 8),
                          _ModernActionButton(
                            active: widget.note.isPinned,
                            activeColor: cs.primary,
                            icon:
                                widget.note.isPinned
                                    ? Icons.push_pin_rounded
                                    : Icons.push_pin_outlined,
                            onTap: () => controller.togglePin(widget.note.id!),
                          ),
                        ],
                      ),
                    ),

                    // Modern corner indicator for pinned notes
                    if (pinned)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.primary.withOpacity(0.7)],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Modern action button for the note card
class _ModernActionButton extends StatelessWidget {
  final bool active;
  final Color activeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.active,
    required this.activeColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                active
                    ? activeColor.withOpacity(0.15)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  active ? activeColor.withOpacity(0.3) : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    active
                        ? activeColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? activeColor : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
