import 'package:flutter/material.dart';
import '../../domain/models/filter_group.dart';
import '../../domain/models/filter_option.dart';

class FilterGroupWidget extends StatefulWidget {
  final FilterGroup group;
  final Set<String> selectedValues;
  final Function(FilterAttribute, String) onOptionSelected;

  const FilterGroupWidget({
    super.key,
    required this.group,
    required this.selectedValues,
    required this.onOptionSelected,
  });

  @override
  State<FilterGroupWidget> createState() => _FilterGroupWidgetState();
}

class _FilterGroupWidgetState extends State<FilterGroupWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Text(
          widget.group.attribute.displayName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.group.options.map((option) {
                final isSelected = widget.selectedValues.contains(option.value);
                return FilterChip(
                  label: Text(
                    '${option.value} (${option.count})',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    widget.onOptionSelected(
                        widget.group.attribute, option.value);
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Theme.of(context).primaryColor,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
