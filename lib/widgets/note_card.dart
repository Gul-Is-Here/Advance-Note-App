import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/views/create_view.dart';
import 'package:note_app/widgets/category_chips.dart';

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
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Glass blur
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: const SizedBox(height: 200, width: double.infinity),
                  ),

                  // Glass background + subtle gradient (stronger when pinned/hovered)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.surface.withOpacity(pinned ? 0.55 : 0.45),
                          cs.surface.withOpacity(pinned ? 0.38 : 0.30),
                        ],
                      ),
                      border: Border.all(
                        color: cs.outline.withOpacity(_hovered ? 0.18 : 0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            _hovered ? 0.18 : 0.10,
                          ),
                          blurRadius: _hovered ? 16 : 8,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      // inner soft highlight
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary.withOpacity(pinned ? 0.10 : 0.06),
                            cs.secondary.withOpacity(pinned ? 0.10 : 0.04),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row
                          Row(
                            children: [
                              if (pinned)
                                Icon(
                                  Icons.push_pin,
                                  size: 18,
                                  color: cs.secondary,
                                ),
                              if (pinned) const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.note.title.isEmpty
                                      ? 'Untitled'
                                      : widget.note.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Content preview
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                textContent.isEmpty
                                    ? 'No content'
                                    : textContent,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // Footer (responsive, no overflow)
                          Row(
                            children: [
                              // Let the chip scale down before overflowing
                              Flexible(
                                fit: FlexFit.tight,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: CategoryChip(
                                      category: widget.note.category,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Date text can shrink/ellipsis on tight widths
                              Flexible(
                                child: Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(widget.note.updatedAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant.withOpacity(
                                      0.72,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-right glass buttons
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        _GlassIconButton(
                          active: widget.note.isFavorite,
                          activeColor: cs.secondary,
                          icon:
                              widget.note.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                          onTap:
                              () => controller.toggleFavorite(widget.note.id!),
                        ),
                        const SizedBox(width: 6),
                        _GlassIconButton(
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

                  // Corner ribbon when pinned
                  if (pinned)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ClipPath(
                        clipper: _CornerClipper(),
                        child: Container(
                          width: 34,
                          height: 34,
                          color: cs.primary,
                          alignment: const Alignment(0.6, -0.6),
                          child: const Icon(
                            Icons.push_pin_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Small glass icon button used for favorite/pin
class _GlassIconButton extends StatelessWidget {
  final bool active;
  final Color activeColor;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.active,
    required this.activeColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: (active ? activeColor : cs.surface).withOpacity(
            active ? 0.25 : 0.18,
          ),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                icon,
                size: 18,
                color: active ? activeColor : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Corner ribbon clipper
class _CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(size.width, 0);
    p.lineTo(size.width, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
