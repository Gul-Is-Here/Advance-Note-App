import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String category;

  const CategoryChip({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: (_) {
          // Optional: Add scale animation on tap
          // Handled by AnimatedContainer for subtle feedback
        },
        child: Chip(
          label: Text(
            category,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: _getCategoryColor(category),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.black.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.15),
          materialTapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF4A00E0); // Deep purple, aligns with app theme
      case 'personal':
        return const Color(0xFF7B1FA2); // Slightly lighter purple for contrast
      case 'ideas':
        return const Color(0xFFE91E63); // Vibrant pink, aligns with app theme
      case 'important':
        return const Color(0xFFF06292); // Softer pink for importance
      default:
        return Colors.grey[600]!; // Neutral grey for undefined categories
    }
  }
}