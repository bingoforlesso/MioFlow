import 'package:flutter/material.dart';
import '../../domain/models/filter_group.dart';

class SelectedFilters extends StatelessWidget {
  final Map<FilterAttribute, Set<String>> selectedFilters;
  final Function(FilterAttribute, String) onRemove;
  final VoidCallback onClearAll;

  const SelectedFilters({
    super.key,
    required this.selectedFilters,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '已选条件',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                child: const Text('清除全部'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedFilters.entries.expand((entry) {
              return entry.value.map((value) {
                return Chip(
                  label: Text('${entry.key.displayName}: $value'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => onRemove(entry.key, value),
                );
              });
            }).toList(),
          ),
        ],
      ),
    );
  }
}