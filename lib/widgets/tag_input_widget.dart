import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controllers/note_controller.dart';

class TagInputWidget extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;

  const TagInputWidget({
    Key? key,
    required this.initialTags,
    required this.onTagsChanged,
  }) : super(key: key);

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RxList<String> _tags = <String>[].obs;
  final RxList<String> _suggestions = <String>[].obs;
  final NoteController _noteController = Get.find<NoteController>();

  @override
  void initState() {
    super.initState();
    _tags.addAll(widget.initialTags);

    // Listen to text changes for autocomplete
    _tagController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _tagController.text.trim().toLowerCase();
    if (text.isEmpty) {
      _suggestions.clear();
      return;
    }

    // Get suggestions from existing tags
    final allTags = _noteController.allTags;
    _suggestions.value =
        allTags
            .where(
              (tag) => tag.toLowerCase().contains(text) && !_tags.contains(tag),
            )
            .take(5)
            .toList();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isEmpty) return;
    if (_tags.contains(trimmedTag)) {
      Get.snackbar('Info', 'Tag already added');
      return;
    }

    setState(() {
      _tags.add(trimmedTag);
      _tagController.clear();
      _suggestions.clear();
    });

    widget.onTagsChanged(_tags.toList());
    _noteController.loadAllTags(); // Refresh tag list
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags.toList());
  }

  @override
  void dispose() {
    _tagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.local_offer_rounded, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Tags',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              if (_tags.isNotEmpty)
                Text(
                  '${_tags.length} tag${_tags.length > 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),

        // Tag input field
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _focusNode.hasFocus
                      ? cs.primary
                      : cs.outline.withOpacity(0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _tagController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Add tags (press Enter)',
              hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.6)),
              prefixIcon: Icon(Icons.tag, color: cs.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onSubmitted: _addTag,
            textInputAction: TextInputAction.done,
          ),
        ),

        // Autocomplete suggestions
        Obx(() {
          if (_suggestions.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline.withOpacity(0.2)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _suggestions.map((suggestion) {
                    return InkWell(
                      onTap: () => _addTag(suggestion),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: cs.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 14,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              suggestion,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          );
        }),

        // Display added tags
        Obx(() {
          if (_tags.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  'No tags added yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.secondary.withOpacity(0.8), cs.secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: cs.secondary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => _removeTag(tag),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          );
        }),

        // Quick tag suggestions (popular tags)
        if (_tags.isEmpty && _noteController.allTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular tags:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _noteController.allTags
                          .take(10)
                          .map(
                            (tag) => InkWell(
                              onTap: () => _addTag(tag),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cs.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
