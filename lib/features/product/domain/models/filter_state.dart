import 'package:freezed_annotation/freezed_annotation.dart';
import 'filter_group.dart';
import 'filter_option.dart';

part 'filter_state.freezed.dart';
part 'filter_state.g.dart';

@freezed
class FilterState with _$FilterState {
  const factory FilterState({
    @Default({}) Map<FilterAttribute, Set<String>> selectedFilters,
    @Default([]) List<FilterGroup> filterGroups,
  }) = _FilterState;

  factory FilterState.fromJson(Map<String, dynamic> json) =>
      _$FilterStateFromJson(json);
}
