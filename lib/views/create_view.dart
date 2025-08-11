import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/models/note_model.dart';
import 'package:note_app/utility/constants.dart';

class CreateNoteView extends StatefulWidget {
  final Note? note;
  const CreateNoteView({super.key, this.note});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor:
            isDark ? Color(0xff212121) : Theme.of(context).primaryColor,
        title: Text(
          widget.note == null ? 'New Note' : 'Edit Note',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildToolbar(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items:
                          AppConstants.categories
                              .where((cat) => cat != 'All')
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: QuillEditor(
                          controller: _quillController,
                          scrollController: _editorScrollController,
                          // : true,
                          focusNode: _editorFocusNode,
                          // autoFocus: false,
                          // readOnly: false,
                          // expands: true,
                          // padding: EdgeInsets.zero,
                          // placeholder: 'Write your note here...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold),
              tooltip: 'Bold',
              onPressed: () => _formatSelection(Attribute.bold),
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              tooltip: 'Italic',
              onPressed: () => _formatSelection(Attribute.italic),
            ),
            IconButton(
              icon: const Icon(Icons.format_underline),
              tooltip: 'Underline',
              onPressed: () => _formatSelection(Attribute.underline),
            ),
            IconButton(
              icon: const Icon(Icons.format_strikethrough),
              tooltip: 'Strikethrough',
              onPressed: () => _formatSelection(Attribute.strikeThrough),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              tooltip: 'Bullet List',
              onPressed: () => _formatSelection(Attribute.ul),
            ),
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Numbered List',
              onPressed: () => _formatSelection(Attribute.ol),
            ),
            IconButton(
              icon: const Icon(Icons.format_quote),
              tooltip: 'Quote',
              onPressed: () => _formatSelection(Attribute.blockQuote),
            ),
            IconButton(
              icon: const Icon(Icons.link),
              tooltip: 'Insert Link',
              onPressed: _insertLink,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: _quillController.undo,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: _quillController.redo,
            ),
          ],
        ),
      ),
    );
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

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final content = jsonEncode(_quillController.document.toDelta().toJson());

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: content,
        category: _selectedCategory,
        isPinned: widget.note?.isPinned ?? false,
        isFavorite: widget.note?.isFavorite ?? false,
      );

      final controller = Get.find<NoteController>();
      if (widget.note == null) {
        controller.addNote(note);
      } else {
        controller.updateNote(note);
      }
    }
  }
}
