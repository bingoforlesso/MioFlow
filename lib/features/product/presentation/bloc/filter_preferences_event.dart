part of 'filter_preferences_bloc.dart';

@freezed
class FilterPreferencesEvent with _$FilterPreferencesEvent {
  const factory FilterPreferencesEvent.started() = _Started;
  const factory FilterPreferencesEvent.toggleFavorite(FilterGroup group) =
      _ToggleFavorite;
  const factory FilterPreferencesEvent.addToHistory(
      Map<String, Set<String>> filters) = _AddToHistory;
  const factory FilterPreferencesEvent.clearHistory() = _ClearHistory;
  const factory FilterPreferencesEvent.applyHistoryItem(
      FilterHistoryItem item) = _ApplyHistoryItem;
}
