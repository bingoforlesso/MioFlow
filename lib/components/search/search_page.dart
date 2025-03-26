import 'package:flutter/material.dart';
import 'filter_panel.dart';
import 'search_results.dart';
import 'selected_filters.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 存储已选择的筛选条件
  Map<String, List<String>> selectedFilters = {};

  // 更新筛选条件
  void updateFilters(String category, List<String> values) {
    setState(() {
      if (values.isEmpty) {
        selectedFilters.remove(category);
      } else {
        selectedFilters[category] = values;
      }
    });
  }

  // 移除单个筛选条件
  void removeFilter(String category, String value) {
    setState(() {
      if (selectedFilters.containsKey(category)) {
        selectedFilters[category]?.remove(value);
        if (selectedFilters[category]?.isEmpty ?? true) {
          selectedFilters.remove(category);
        }
      }
    });
  }

  // 清除所有筛选条件
  void clearAllFilters() {
    setState(() {
      selectedFilters.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部已选筛选条件
          SelectedFilters(
            selectedFilters: selectedFilters,
            onRemove: removeFilter,
            onClearAll: clearAllFilters,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧筛选面板
                SizedBox(
                  width: 250,
                  child: FilterPanel(
                    selectedFilters: selectedFilters,
                    onFilterChanged: updateFilters,
                  ),
                ),
                // 右侧搜索结果
                Expanded(
                  child: SearchResults(
                    selectedFilters: selectedFilters,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}