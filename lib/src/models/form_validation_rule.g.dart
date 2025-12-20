// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_validation_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormValidationRule _$FormValidationRuleFromJson(Map<String, dynamic> json) =>
    FormValidationRule(
      type: $enumDecode(_$FormValidationRuleTypeEnumMap, json['type']),
      value: json['value'],
      message: json['message'] as String,
    );

Map<String, dynamic> _$FormValidationRuleToJson(FormValidationRule instance) =>
    <String, dynamic>{
      'type': _$FormValidationRuleTypeEnumMap[instance.type]!,
      'value': ?instance.value,
      'message': instance.message,
    };

const _$FormValidationRuleTypeEnumMap = {
  FormValidationRuleType.required: 'REQUIRED',
  FormValidationRuleType.min: 'MIN',
  FormValidationRuleType.max: 'MAX',
  FormValidationRuleType.pattern: 'PATTERN',
  FormValidationRuleType.allowedFileExtensions: 'ALLOWED_FILE_EXTENSIONS',
};
