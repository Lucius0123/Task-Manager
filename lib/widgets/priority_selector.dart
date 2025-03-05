import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onPrioritySelected;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPriorityOption(context, 'Low', 'low'),
        const SizedBox(width: 16),
        _buildPriorityOption(context, 'Medium', 'medium'),
        const SizedBox(width: 16),
        _buildPriorityOption(context, 'High', 'high'),
      ],
    );
  }

  Widget _buildPriorityOption(BuildContext context, String label, String value) {
    final isSelected = (selectedPriority == value);

    Color priorityColor;
    switch (value) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }
    return Expanded(
      child: InkWell(
        onTap: () => onPrioritySelected(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? priorityColor.withOpacity(0.2) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? priorityColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? priorityColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
