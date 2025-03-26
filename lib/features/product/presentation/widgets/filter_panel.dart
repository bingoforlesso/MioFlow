import 'package:flutter/material.dart';
import '../../domain/models/filter_group.dart';
import '../../domain/models/filter_option.dart';
import 'filter_group_widget.dart';

class FilterPanel extends StatefulWidget {
  final List<FilterGroup> filterGroups;
  final Map<FilterAttribute, Set<String>> selectedFilters;
  final Function(FilterAttribute, String, bool) onFilterSelected;
  final VoidCallback onClearFilters;
  final Function(FilterGroup) onFavoriteToggle;
  final Set<FilterAttribute> favoriteFilters;

  const FilterPanel({
    super.key,
    required this.filterGroups,
    required this.selectedFilters,
    required this.onFilterSelected,
    required this.onClearFilters,
    required this.onFavoriteToggle,
    required this.favoriteFilters,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyFavorites = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FilterGroup> get _filteredGroups {
    var groups = widget.filterGroups;

    // 仅显示收藏的筛选条件
    if (_showOnlyFavorites) {
      groups = groups
          .where((group) => widget.favoriteFilters.contains(group.attribute))
          .toList();
    }

    // 搜索筛选
    if (_searchQuery.isNotEmpty) {
      groups = groups
          .map((group) {
            final filteredOptions = group.options
                .where((option) =>
                    option.value
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    group.attribute.displayName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

            if (filteredOptions.isEmpty) return null;

            return FilterGroup(
              attribute: group.attribute,
              options: filteredOptions,
            );
          })
          .whereType<FilterGroup>()
          .toList();
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredGroups.length,
              itemBuilder: (context, index) {
                final group = _filteredGroups[index];
                return ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(group.attribute.displayName)),
                      IconButton(
                        icon: Icon(
                          widget.favoriteFilters.contains(group.attribute)
                              ? Icons.star
                              : Icons.star_border,
                          color:
                              widget.favoriteFilters.contains(group.attribute)
                                  ? Colors.amber
                                  : null,
                        ),
                        onPressed: () => widget.onFavoriteToggle(group),
                      ),
                    ],
                  ),
                  children: group.options.map((option) {
                    final isSelected = widget.selectedFilters[group.attribute]
                            ?.contains(option.value) ??
                        false;
                    return CheckboxListTile(
                      title: Text(option.value),
                      subtitle: Text('(${option.count}个产品)'),
                      value: isSelected,
                      onChanged: (value) {
                        widget.onFilterSelected(
                          group.attribute,
                          option.value,
                          value ?? false,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '筛选条件',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _showOnlyFavorites ? Icons.star : Icons.star_border,
                  color: _showOnlyFavorites ? Colors.amber : null,
                ),
                onPressed: () {
                  setState(() {
                    _showOnlyFavorites = !_showOnlyFavorites;
                  });
                },
                tooltip: '显示收藏的筛选条件',
              ),
              if (widget.selectedFilters.isNotEmpty)
                TextButton(
                  onPressed: widget.onClearFilters,
                  child: const Text('清除全部'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索筛选条件...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }
}
