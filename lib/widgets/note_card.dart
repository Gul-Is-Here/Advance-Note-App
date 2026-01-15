import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/utility/app_colors.dart';
import 'package:note_app/views/create_view.dart';

import '../models/note_model.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  String _getPlainText() {
    try {
      final document = Document.fromJson(jsonDecode(widget.note.content));
      return document.toPlainText().trim();
    } catch (_) {
      return widget.note.content;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work_outline_rounded;
      case 'Personal':
        return Icons.person_outline_rounded;
      case 'Ideas':
        return Icons.lightbulb_outline_rounded;
      case 'Todo':
      case 'To-Do':
        return Icons.check_circle_outline_rounded;
      case 'General':
      default:
        return Icons.note_outlined;
    }
  }

  Color _getCategoryColor(String category, bool isDark) {
    switch (category) {
      case 'Work':
        return isDark ? Colors.blue[300]! : Colors.blue[700]!;
      case 'Personal':
        return isDark ? Colors.purple[300]! : Colors.purple[700]!;
      case 'Ideas':
        return isDark ? Colors.amber[300]! : Colors.amber[700]!;
      case 'Todo':
      case 'To-Do':
        return AppColors.primaryGreen;
      case 'General':
      default:
        return isDark ? Colors.grey[400]! : Colors.grey[700]!;
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case 'Work':
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 'Personal':
        return [Colors.purple.shade400, Colors.purple.shade600];
      case 'Ideas':
        return [Colors.amber.shade400, Colors.amber.shade600];
      case 'Todo':
      case 'To-Do':
        return [
          AppColors.primaryGreen,
          AppColors.primaryGreen.withOpacity(0.7),
        ];
      case 'General':
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.find<NoteController>();
    final textContent = _getPlainText();
    final pinned = widget.note.isPinned;
    final categoryColor = _getCategoryColor(widget.note.category, isDark);
    final categoryGradient = _getCategoryGradient(widget.note.category);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTapDown: (_) => _animationController?.forward(),
          onTapUp: (_) => _animationController?.reverse(),
          onTapCancel: () => _animationController?.reverse(),
          onTap: () async {
            // Check if note is locked and requires authentication
            final canView = await controller.canViewNote(widget.note);
            if (canView) {
              Get.to(
                () => CreateNoteView(note: widget.note),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              );
            }
          },
          child: ScaleTransition(
            scale: _scaleAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? cs.surface : Colors.white,
                    isDark ? cs.surface.withOpacity(0.95) : Colors.grey.shade50,
                  ],
                ),
                border: Border.all(
                  color:
                      pinned
                          ? categoryColor.withOpacity(0.5)
                          : (_hovered
                              ? categoryColor.withOpacity(0.3)
                              : cs.outline.withOpacity(0.1)),
                  width: pinned ? 2.5 : (_hovered ? 1.5 : 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _hovered
                            ? categoryColor.withOpacity(0.15)
                            : cs.shadow.withOpacity(0.08),
                    blurRadius: _hovered ? 20 : 10,
                    spreadRadius: _hovered ? 2 : 0,
                    offset: Offset(0, _hovered ? 8 : 4),
                  ),
                  if (pinned)
                    BoxShadow(
                      color: categoryColor.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Gradient accent bar on left
                    if (pinned || widget.note.isFavorite)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: categoryGradient,
                            ),
                          ),
                        ),
                      ),

                    // Main content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with gradient background
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                categoryColor.withOpacity(0.08),
                                categoryColor.withOpacity(0.03),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status badges row
                              if (pinned ||
                                  widget.note.isLocked ||
                                  widget.note.reminderDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      if (pinned)
                                        _ModernBadge(
                                          icon: Icons.push_pin_rounded,
                                          color: categoryColor,
                                          label: 'Pinned',
                                        ),
                                      if (widget.note.isLocked)
                                        _ModernBadge(
                                          icon: Icons.lock_rounded,
                                          color: Colors.orange,
                                          label: 'Locked',
                                        ),
                                      if (widget.note.reminderDate != null)
                                        _ModernBadge(
                                          icon:
                                              Icons
                                                  .notifications_active_rounded,
                                          color: Colors.blue,
                                          label: 'Reminder',
                                        ),
                                    ],
                                  ),
                                ),

                              // Title and actions
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.note.title.isEmpty
                                          ? 'Untitled Note'
                                          : widget.note.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: cs.onSurface,
                                            fontSize: 18,
                                            height: 1.3,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Quick actions with modern design
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _ModernActionButton(
                                        active: widget.note.isFavorite,
                                        icon:
                                            widget.note.isFavorite
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                        color: Colors.red.shade400,
                                        onTap:
                                            () => controller.toggleFavorite(
                                              widget.note.id!,
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      _ModernActionButton(
                                        active: widget.note.isPinned,
                                        icon:
                                            widget.note.isPinned
                                                ? Icons.push_pin_rounded
                                                : Icons.push_pin_outlined,
                                        color: categoryColor,
                                        onTap:
                                            () => controller.togglePin(
                                              widget.note.id!,
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      _ModernActionButton(
                                        active: widget.note.isLocked,
                                        icon:
                                            widget.note.isLocked
                                                ? Icons.lock_rounded
                                                : Icons.lock_open_rounded,
                                        color: Colors.orange.shade400,
                                        onTap: () async {
                                          await controller.toggleLock(
                                            widget.note.id!,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Body content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tags with modern pill design
                              if (widget.note.tags.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      widget.note.tags
                                          .take(3)
                                          .map(
                                            (tag) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    categoryColor.withOpacity(
                                                      0.15,
                                                    ),
                                                    categoryColor.withOpacity(
                                                      0.05,
                                                    ),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: categoryColor
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.tag_rounded,
                                                    size: 12,
                                                    color: categoryColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    tag,
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: categoryColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 11,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Content preview with better styling
                              Text(
                                textContent.isEmpty
                                    ? 'No content yet. Tap to add...'
                                    : textContent,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      textContent.isEmpty
                                          ? cs.onSurfaceVariant.withOpacity(0.4)
                                          : cs.onSurfaceVariant,
                                  height: 1.6,
                                  fontSize: 14,
                                  fontStyle:
                                      textContent.isEmpty
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Footer with modern design
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.1)
                                    : Colors.grey.shade50.withOpacity(0.5),
                            border: Border(
                              top: BorderSide(
                                color: cs.outline.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Category badge with gradient
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: categoryGradient,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: categoryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(widget.note.category),
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.note.category,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            letterSpacing: 0.3,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Date with icon
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: cs.onSurfaceVariant.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yy',
                                      ).format(widget.note.updatedAt),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
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
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Badge Widget
class _ModernBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _ModernBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Action Button Widget
class _ModernActionButton extends StatelessWidget {
  final bool active;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.active,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? color : color.withOpacity(0.5),
        ),
      ),
    );
  }
}
