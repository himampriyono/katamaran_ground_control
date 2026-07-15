import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import '../models/parameter_metadata.dart';

class ParameterMetadataService {
  static final Map<String, ParameterMetadata> _metadata = {};
  static Future<void> load() async {
    final xmlString = await rootBundle.loadString(
      'assets/parameters/apm.pdef.xml',
    );

    final document = XmlDocument.parse(xmlString);
    final params = document.findAllElements("param");

    for (final element in params) {
      final fullName = element.getAttribute("name") ?? "";
      final index = fullName.lastIndexOf(":");
      final name = index == -1 ? fullName : fullName.substring(index + 1);
      final metadata = ParameterMetadata(
        name: name,
        humanName: element.getAttribute("humanName") ?? "",
        description: element.getAttribute("documentation") ?? "",
        userLevel: element.getAttribute("user"),
        range: _getFieldValue(element, "Range"),
        increment: _getFieldValue(element, "Increment"),
        units: _getFieldValue(element, "Units"),
        unitText: _getFieldValue(element, "UnitText"),
        values: _getValues(element),
      );

      _metadata[name] = metadata;
    }
  }

  static ParameterMetadata? get(String name) {
    return _metadata[name];
  }

  static String? _getFieldValue(XmlElement param, String fieldName) {
    for (final field in param.findElements("field")) {
      if (field.getAttribute("name") == fieldName) {
        return field.innerText.trim();
      }
    }

    return null;
  }

  static Map<int, String> _getValues(XmlElement params) {
    final result = <int, String>{};
    final values = params.findElements("values");

    if (values.isEmpty) {
      return result;
    }

    for (final value in values.first.findElements("value")) {
      final code = int.tryParse(value.getAttribute("code") ?? "");

      if (code != null) {
        result[code] = value.innerText.trim();
      }
    }
    return result;
  }
}
