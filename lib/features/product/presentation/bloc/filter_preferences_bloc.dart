import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences.dart';
import '../../domain/models/filter_group.dart';

part 'filter_preferences_event.dart';
part 'filter_preferences_state.dart';
part 'filter_preferences_bloc.freezed.dart';

class FilterPreferencesBloc
    extends Bloc<FilterPreferencesEvent, FilterPreferencesState> {
  final SharedPreferences _prefs;
  static const _favoriteFiltersKey = 'favorite_filters';
  static const _filterHistoryKey = 'filter_history';
  static const _maxHistoryItems = 10;

  FilterPreferencesBloc(this._prefs)
      : super(const FilterPreferencesState.initial()) {
    on<FilterPreferencesEvent>((event, emit) async {
      await event.when(
        started: () async {
          final favoriteFilters =
              _prefs.getStringList(_favoriteFiltersKey)?.toSet() ?? {};
          final filterHistory = _prefs.getStringList(_filterHistoryKey)?.map(
                  (json) => FilterHistoryItem.fromJson(
                      Map<String, dynamic>.from(jsonDecode(json)))) ??
              [];
          emit(FilterPreferencesState.loaded(
            favoriteFilters: favoriteFilters,
            filterHistory: filterHistory.toList(),
          ));
        },
        toggleFavorite: (FilterGroup group) async {
          final currentState = state;
          if (currentState is! _Loaded) return;

          final favoriteFilters =
              Set<String>.from(currentState.favoriteFilters);
          if (favoriteFilters.contains(group.attribute)) {
            favoriteFilters.remove(group.attribute);
          } else {
            favoriteFilters.add(group.attribute);
          }

          await _prefs.setStringList(
              _favoriteFiltersKey, favoriteFilters.toList());
          emit(currentState.copyWith(favoriteFilters: favoriteFilters));
        },
        addToHistory: (Map<String, Set<String>> filters) async {
          final currentState = state;
          if (currentState is! _Loaded) return;

          final historyItem = FilterHistoryItem(
            timestamp: DateTime.now(),
            filters: filters,
          );

          final updatedHistory = [
            historyItem,
            ...currentState.filterHistory,
          ].take(_maxHistoryItems).toList();

          await _prefs.setStringList(
            _filterHistoryKey,
            updatedHistory.map((item) => jsonEncode(item.toJson())).toList(),
          );

          emit(currentState.copyWith(filterHistory: updatedHistory));
        },
        clearHistory: () async {
          final currentState = state;
          if (currentState is! _Loaded) return;

          await _prefs.remove(_filterHistoryKey);
          emit(currentState.copyWith(filterHistory: []));
        },
        applyHistoryItem: (FilterHistoryItem item) async {
          // 这个事件会被ProductListBloc处理
          // 这里只是将该项移到历史记录的顶部
          final currentState = state;
          if (currentState is! _Loaded) return;

          final updatedHistory = [
            item,
            ...currentState.filterHistory
                .where((historyItem) => historyItem != item),
          ];

          await _prefs.setStringList(
            _filterHistoryKey,
            updatedHistory.map((item) => jsonEncode(item.toJson())).toList(),
          );

          emit(currentState.copyWith(filterHistory: updatedHistory));
        },
      );
    });
  }
}
