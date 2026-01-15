import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/controllers/folder_controller.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/services/ad_service.dart';
import 'package:note_app/services/pdf_export_service.dart';
import 'package:note_app/widgets/tag_input_widget.dart';
import 'package:share_plus/share_plus.dart';

class CreateNoteView extends StatefulWidget {
  final Note? note;
  final String? preSelectedCategory;

  const CreateNoteView({super.key, this.note, this.preSelectedCategory});

  @override
  State<CreateNoteView> createState() => _CreateNoteViewState();
}

class _CreateNoteViewState extends State<CreateNoteView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  String _selectedCategory = 'General';
  List<String> _tags = [];
  DateTime? _reminderDate;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _quillController = QuillController(
      document:
          widget.note != null
              ? Document.fromJson(jsonDecode(widget.note!.content))
              : Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _selectedCategory = widget.note!.category;
      _tags = List.from(widget.note!.tags);
      _reminderDate = widget.note!.reminderDate;
    } else if (widget.preSelectedCategory != null) {
      // Set the pre-selected category for new notes
      _selectedCategory = widget.preSelectedCategory!;
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_rounded, color: cs.onPrimary),
        ),
        backgroundColor: cs.primary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primary, cs.primary.withOpacity(0.8)],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.note == null
                    ? Icons.note_add_rounded
                    : Icons.edit_note_rounded,
                color: cs.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.note == null ? 'New Note' : 'Edit Note',
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Export/Share menu (only for existing notes)
          if (widget.note != null)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: cs.onPrimary,
                  size: 20,
                ),
              ),
              tooltip: 'More options',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) async {
                if (value == 'export_pdf') {
                  await _exportToPdf();
                } else if (value == 'share') {
                  await _shareNote();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'export_pdf',
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text('Export as PDF'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(
                            Icons.share_rounded,
                            color: cs.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text('Share Note'),
                        ],
                      ),
                    ),
                  ],
            ),

          // Lock/Unlock button (only show for existing notes)
          if (widget.note != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color:
                    widget.note!.isLocked
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      widget.note!.isLocked
                          ? Colors.amber.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  widget.note!.isLocked
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  color: widget.note!.isLocked ? Colors.amber : cs.onPrimary,
                ),
                tooltip: widget.note!.isLocked ? 'Unlock note' : 'Lock note',
                onPressed: () async {
                  final controller = Get.find<NoteController>();
                  await controller.toggleLock(widget.note!.id!);
                  setState(() {
                    widget.note!.isLocked = !widget.note!.isLocked;
                  });
                },
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.save_rounded, color: cs.onPrimary),
              tooltip: 'Save note',
              onPressed: _saveNote,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Toolbar
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? cs.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildToolbar(),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field with modern design
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? cs.surface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: cs.shadow.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _titleController,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              hintText: 'Enter note title...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cs.primary.withOpacity(0.2),
                                      cs.primary.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.title_rounded,
                                  color: cs.primary,
                                  size: 20,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown with modern design
                        Builder(
                          builder: (context) {
                            final folderController =
                                Get.find<FolderController>();
                            final categories = folderController.allCategories;

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark ? cs.surface : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.shadow.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                items:
                                    categories
                                        .map(
                                          (category) => DropdownMenuItem(
                                            value: category,
                                            child: Text(
                                              category,
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  labelStyle: TextStyle(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          cs.primary.withOpacity(0.2),
                                          cs.primary.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.category_rounded,
                                      color: cs.primary,
                                      size: 20,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tag Input Widget
                        TagInputWidget(
                          initialTags: _tags,
                          onTagsChanged: (tags) {
                            setState(() {
                              _tags = tags;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Reminder Section
                        _buildReminderSection(),
                        const SizedBox(height: 16),

                        // Editor Section with modern design
                        Container(
                          constraints: const BoxConstraints(minHeight: 300),
                          decoration: BoxDecoration(
                            color: isDark ? cs.surface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outline.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.shadow.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cs.primary.withOpacity(0.08),
                                      cs.primary.withOpacity(0.03),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note_rounded,
                                      color: cs.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Content',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Editor
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 250,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: QuillEditor(
                                  controller: _quillController,
                                  scrollController: _editorScrollController,
                                  focusNode: _editorFocusNode,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toolbarButton(
              icon: Icons.format_bold_rounded,
              tooltip: 'Bold',
              onPressed: () => _formatSelection(Attribute.bold),
              color: cs.primary,
            ),
            _toolbarButton(
              icon: Icons.format_italic_rounded,
              tooltip: 'Italic',
              onPressed: () => _formatSelection(Attribute.italic),
              color: cs.primary,
            ),
            _toolbarButton(
              icon: Icons.format_underline_rounded,
              tooltip: 'Underline',
              onPressed: () => _formatSelection(Attribute.underline),
              color: cs.primary,
            ),
            _toolbarButton(
              icon: Icons.format_strikethrough_rounded,
              tooltip: 'Strikethrough',
              onPressed: () => _formatSelection(Attribute.strikeThrough),
              color: cs.primary,
            ),
            Container(
              width: 1,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: cs.outline.withOpacity(0.2),
            ),
            _toolbarButton(
              icon: Icons.format_list_bulleted_rounded,
              tooltip: 'Bullet List',
              onPressed: () => _formatSelection(Attribute.ul),
              color: Colors.orange,
            ),
            _toolbarButton(
              icon: Icons.format_list_numbered_rounded,
              tooltip: 'Numbered List',
              onPressed: () => _formatSelection(Attribute.ol),
              color: Colors.orange,
            ),
            _toolbarButton(
              icon: Icons.format_quote_rounded,
              tooltip: 'Quote',
              onPressed: () => _formatSelection(Attribute.blockQuote),
              color: Colors.purple,
            ),
            _toolbarButton(
              icon: Icons.link_rounded,
              tooltip: 'Insert Link',
              onPressed: _insertLink,
              color: Colors.blue,
            ),
            Container(
              width: 1,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: cs.outline.withOpacity(0.2),
            ),
            _toolbarButton(
              icon: Icons.undo_rounded,
              tooltip: 'Undo',
              onPressed: _quillController.undo,
              color: Colors.grey,
            ),
            _toolbarButton(
              icon: Icons.redo_rounded,
              tooltip: 'Redo',
              onPressed: _quillController.redo,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _reminderDate != null
                  ? cs.primary.withOpacity(0.3)
                  : cs.outline.withOpacity(0.1),
          width: _reminderDate != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withOpacity(0.2),
                      cs.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.alarm_rounded, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Text(
                'Reminder',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              if (_reminderDate != null)
                Container(
                  decoration: BoxDecoration(
                    color: cs.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, size: 18),
                    color: cs.error,
                    tooltip: 'Remove reminder',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _reminderDate = null;
                      });
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_reminderDate == null)
            // Quick reminder buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickReminderButton(
                  '1 hour',
                  Icons.access_time_rounded,
                  DateTime.now().add(const Duration(hours: 1)),
                ),
                _quickReminderButton(
                  'Tomorrow',
                  Icons.wb_sunny_rounded,
                  DateTime.now().add(const Duration(days: 1)),
                ),
                _quickReminderButton(
                  'Next week',
                  Icons.calendar_today_rounded,
                  DateTime.now().add(const Duration(days: 7)),
                ),
                OutlinedButton.icon(
                  onPressed: _pickCustomReminder,
                  icon: const Icon(Icons.event_rounded, size: 18),
                  label: const Text('Custom'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            )
          else
            // Display selected reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.15),
                    cs.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatReminderDate(_reminderDate!),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatReminderTime(_reminderDate!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _pickCustomReminder,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      backgroundColor: cs.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _quickReminderButton(String label, IconData icon, DateTime dateTime) {
    final cs = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _reminderDate = dateTime;
        });
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _pickCustomReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            _reminderDate != null
                ? TimeOfDay.fromDateTime(_reminderDate!)
                : TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _reminderDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatReminderDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatReminderTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return 'at $hour:$minute';
  }

  void _formatSelection(Attribute attribute) {
    _quillController.formatSelection(attribute);
    _editorFocusNode.requestFocus();
  }

  void _insertLink() {
    final textController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Insert Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: 'Display Text'),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Insert'),
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  _quillController.formatSelection(
                    LinkAttribute(urlController.text),
                  );
                  Navigator.of(context).pop();
                  _editorFocusNode.requestFocus();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final content = jsonEncode(_quillController.document.toDelta().toJson());

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: content,
        category: _selectedCategory,
        isPinned: widget.note?.isPinned ?? false,
        isFavorite: widget.note?.isFavorite ?? false,
        isLocked: widget.note?.isLocked ?? false,
        tags: _tags,
        reminderDate: _reminderDate,
      );

      final controller = Get.find<NoteController>();

      // Show interstitial ad before saving (50% of the time)
      final adService = AdService.instance;
      // Show ad 50% of the time when saving notes
      if (DateTime.now().second % 2 == 0) {
        print('🎯 Save action - Attempting to show ad');
        adService.showInterstitialAd();
      }

      if (widget.note == null) {
        await controller.addNote(note);
        // Schedule reminder if set
        if (_reminderDate != null && note.id != null) {
          await controller.setReminder(note, _reminderDate!);
        }
      } else {
        await controller.updateNote(note);
        // Update reminder
        if (_reminderDate != null) {
          await controller.setReminder(note, _reminderDate!);
        } else if (widget.note?.reminderDate != null) {
          // Cancel reminder if it was removed
          await controller.cancelReminder(note);
        }
      }

      // Close the screen after successful save
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // Export note to PDF
  Future<void> _exportToPdf() async {
    if (widget.note == null) {
      Get.snackbar(
        'Info',
        'Please save the note first before exporting',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await PdfExportService.instance.exportNoteToPdf(widget.note!);
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }
    } catch (e) {
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }
      Get.snackbar(
        'Error',
        'Failed to export PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Share note as plain text
  Future<void> _shareNote() async {
    if (widget.note == null) {
      Get.snackbar(
        'Info',
        'Please save the note first before sharing',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final plainText = _getPlainTextFromQuill();
      final shareText = '''
${widget.note!.title}

Category: ${widget.note!.category}
${widget.note!.tags.isNotEmpty ? 'Tags: ${widget.note!.tags.join(', ')}' : ''}

$plainText
''';

      await Share.share(shareText, subject: widget.note!.title);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share note: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get plain text from Quill editor
  String _getPlainTextFromQuill() {
    try {
      return _quillController.document.toPlainText().trim();
    } catch (_) {
      return '';
    }
  }
}
