import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_app/controllers/note_controller.dart';
import 'package:note_app/views/create_view.dart';
import 'package:note_app/widgets/category_chips.dart';

import '../models/note_model.dart'; // Add this import

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  // Helper method to extract plain text from Quill's Delta JSON
  String _getPlainText() {
    try {
      final document = Document.fromJson(jsonDecode(note.content));
      return document.toPlainText();
    } catch (e) {
      return note.content; // Fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NoteController>();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: note.isPinned ? 4 : 2,
      child: InkWell(
        onTap: () => Get.to(() => CreateNoteView(note: note)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.isPinned)
                    Icon(Icons.push_pin, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: note.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => controller.toggleFavorite(note.id!),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: note.isPinned ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => controller.togglePin(note.id!),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              SizedBox(height: 8),
              Text(
                _getPlainText(), // Use the parsed plain text here
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  CategoryChip(category: note.category),
                  Spacer(),
                  Text(
                    DateFormat('MMM dd, yyyy').format(note.updatedAt),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
