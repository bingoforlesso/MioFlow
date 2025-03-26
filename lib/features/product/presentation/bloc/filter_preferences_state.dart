part of 'filter_preferences_bloc.dart';

@freezed
class FilterPreferencesState with _$FilterPreferencesState {
  const factory FilterPreferencesState.initial() = _Initial;
  const factory FilterPreferencesState.loaded({
    required Set<String> favoriteFilters,
    required List<FilterHistoryItem> filterHistory,
  }) = _Loaded;
}

@freezed
class FilterHistoryItem with _$FilterHistoryItem {
  const factory FilterHistoryItem({
    required DateTime timestamp,
    required Map<String, Set<String>> filters,
  }) = _FilterHistoryItem;

  factory FilterHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$FilterHistoryItemFromJson(json);
}
