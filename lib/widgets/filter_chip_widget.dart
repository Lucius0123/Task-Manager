import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
 final String label;
 final  bool selected;
  final Function(bool) onSelected;
   const FilterChipWidget({super.key, required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).toInt()),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}
