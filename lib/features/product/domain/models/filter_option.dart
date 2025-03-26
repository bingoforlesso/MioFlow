import 'package:freezed_annotation/freezed_annotation.dart';
import 'filter_group.dart';

part 'filter_option.freezed.dart';
part 'filter_option.g.dart';

@freezed
class FilterOption with _$FilterOption {
  const factory FilterOption({
    required FilterAttribute filterAttribute,
    required String value,
    required int count,
  }) = _FilterOption;

  factory FilterOption.fromJson(Map<String, dynamic> json) =>
      _$FilterOptionFromJson(json);
}
