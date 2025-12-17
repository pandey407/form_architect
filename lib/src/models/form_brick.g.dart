// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_brick.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormBrick<T> _$FormBrickFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => FormBrick<T>(
  key: json['key'] as String,
  type: $enumDecode(_$FormBrickTypeEnumMap, json['type']),
  label: json['label'] as String?,
  hint: json['hint'] as String?,
  value: _$nullableGenericFromJson(json['value'], fromJsonT),
  values: (json['values'] as List<dynamic>?)?.map(fromJsonT).toList(),
  options: (json['options'] as List<dynamic>?)
      ?.map(
        (e) => FormBrickOption<T>.fromJson(
          e as Map<String, dynamic>,
          (value) => fromJsonT(value),
        ),
      )
      .toList(),
  validation: (json['validation'] as List<dynamic>?)
      ?.map((e) => FormValidationRule.fromJson(e as Map<String, dynamic>))
      .toList(),
  isEnabled: json['isEnabled'] as bool? ?? true,
  range: (json['range'] as List<dynamic>?)?.map(fromJsonT).toList(),
  flex: (json['flex'] as num?)?.toInt(),
);

Map<String, dynamic> _$FormBrickToJson<T>(
  FormBrick<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'flex': ?instance.flex,
  'key': instance.key,
  'type': _$FormBrickTypeEnumMap[instance.type]!,
  'label': ?instance.label,
  'hint': ?instance.hint,
  'value': ?_$nullableGenericToJson(instance.value, toJsonT),
  'values': ?instance.values?.map(toJsonT).toList(),
  'options': ?instance.options
      ?.map((e) => e.toJson((value) => toJsonT(value)))
      .toList(),
  'validation': ?instance.validation,
  'isEnabled': instance.isEnabled,
  'range': ?instance.range?.map(toJsonT).toList(),
};

const _$FormBrickTypeEnumMap = {
  FormBrickType.text: 'TEXT',
  FormBrickType.textArea: 'TEXTAREA',
  FormBrickType.password: 'PASSWORD',
  FormBrickType.float: 'FLOAT',
  FormBrickType.integer: 'INTEGER',
  FormBrickType.radio: 'RADIO',
  FormBrickType.toggle: 'TOGGLE',
  FormBrickType.singleSelectdropdown: 'SINGLE_SELECT_DROPDOWN',
  FormBrickType.multiSelectDropdown: 'MULTI_SELECT_DROPDOWN',
  FormBrickType.date: 'DATE',
  FormBrickType.time: 'TIME',
  FormBrickType.dateTime: 'DATE_TIME',
  FormBrickType.image: 'IMAGE',
  FormBrickType.video: 'VIDEO',
  FormBrickType.file: 'FILE',
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

FormBrickOption<T> _$FormBrickOptionFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => FormBrickOption<T>(
  value: fromJsonT(json['value']),
  label: json['label'] as String,
  disabled: json['disabled'] as bool? ?? false,
);

Map<String, dynamic> _$FormBrickOptionToJson<T>(
  FormBrickOption<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'value': toJsonT(instance.value),
  'label': instance.label,
  'disabled': instance.disabled,
};
