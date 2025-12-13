// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_masonry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormMasonry _$FormMasonryFromJson(Map<String, dynamic> json) => FormMasonry(
  type: $enumDecode(_$FormMasonryTypeEnumMap, json['type']),
  spacing: (json['spacing'] as num?)?.toDouble(),
  children: FormMasonry._childrenFromJson(json['children'] as List),
  flex: (json['flex'] as num?)?.toInt(),
);

Map<String, dynamic> _$FormMasonryToJson(FormMasonry instance) =>
    <String, dynamic>{
      'flex': ?instance.flex,
      'type': _$FormMasonryTypeEnumMap[instance.type]!,
      'spacing': ?instance.spacing,
      'children': FormMasonry._childrenToJson(instance.children),
    };

const _$FormMasonryTypeEnumMap = {
  FormMasonryType.row: 'ROW',
  FormMasonryType.column: 'COL',
};
