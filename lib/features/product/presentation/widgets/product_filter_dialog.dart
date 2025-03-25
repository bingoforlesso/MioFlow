import 'package:flutter/material.dart';

class ProductFilterDialog extends StatefulWidget {
  final Map<String, Set<String>> attributes;
  final Map<String, List<String>> activeFilters;
  final Function(Map<String, List<String>>) onApplyFilters;

  const ProductFilterDialog({
    Key? key,
    required this.attributes,
    required this.activeFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<ProductFilterDialog> createState() => _ProductFilterDialogState();
}

class _ProductFilterDialogState extends State<ProductFilterDialog> {
  late Map<String, List<String>> selectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = Map.from(widget.activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('筛选条件'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.attributes.entries.map((entry) {
            return _buildFilterSection(entry.key, entry.value.toList());
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onApplyFilters(selectedFilters);
            Navigator.pop(context);
          },
          child: const Text('应用'),
        ),
      ],
    );
  }

  Widget _buildFilterSection(String attribute, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attribute,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Wrap(
          spacing: 8,
          children: values.map((value) {
            final isSelected = selectedFilters[attribute]?.contains(value) ?? false;
            return FilterChip(
              label: Text(value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedFilters.update(
                      attribute,
                      (list) => [...list, value],
                      ifAbsent: () => [value],
                    );
                  } else {
                    selectedFilters.update(
                      attribute,
                      (list) => list..remove(value),
                      ifAbsent: () => [],
                    );
                    if (selectedFilters[attribute]!.isEmpty) {
                      selectedFilters.remove(attribute);
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}