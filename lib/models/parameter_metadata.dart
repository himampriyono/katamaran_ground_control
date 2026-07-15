import 'package:flutter/material.dart';

class ParameterMetadata {
  final String name;
  final String humanName;
  final String description;

  final String? range;
  final String? increment;
  final String? userLevel;
  final String? units;
  final String? unitText;
  final Map<int, String>? values;

  const ParameterMetadata({
    required this.name,
    required this.humanName,
    required this.description,

    this.range,
    this.increment,
    this.userLevel,
    this.units,
    this.unitText,
    this.values
  });

  String get tooltip {
    return "$humanName\n\n"
        "$description\n\n"
        "Range: ${range ?? "-"}";
  }
}
