// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_validation_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormValidationRule _$FormValidationRuleFromJson(Map<String, dynamic> json) =>
    FormValidationRule(
      type: $enumDecode(_$FormValidationRuleTypeEnumMap, json['type']),
      value: json['value'],
    );

Map<String, dynamic> _$FormValidationRuleToJson(FormValidationRule instance) =>
    <String, dynamic>{
      'type': _$FormValidationRuleTypeEnumMap[instance.type]!,
      'value': ?instance.value,
    };

const _$FormValidationRuleTypeEnumMap = {
  FormValidationRuleType.required: 'REQUIRED',
  FormValidationRuleType.email: 'EMAIL',
  FormValidationRuleType.min: 'MIN',
  FormValidationRuleType.max: 'MAX',
  FormValidationRuleType.pattern: 'PATTERN',
};
