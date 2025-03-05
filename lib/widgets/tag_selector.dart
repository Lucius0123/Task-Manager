import 'package:flutter/material.dart';

class TagsSelector extends StatelessWidget {
  final List<String> selectedTags;
  final List<String> availableTags;
  final Function(String) onTagToggle;

  const TagsSelector({
    Key? key,
    required this.selectedTags,
    required this.availableTags,
    required this.onTagToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (_) => onTagToggle(tag),
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }
}
