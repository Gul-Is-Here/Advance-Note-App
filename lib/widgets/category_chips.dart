import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  
  const CategoryChip({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(category),
      backgroundColor: _getCategoryColor(category),
      labelStyle: TextStyle(color: Colors.white),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work': return Colors.blue;
      case 'personal': return Colors.green;
      case 'ideas': return Colors.purple;
      case 'important': return Colors.red;
      default: return Colors.grey;
    }
  }
}