import 'package:flutter/material.dart';
import '../../../models/mav_parameter.dart';
import '../../../models/parameter_metadata.dart';
import '../../../services/parameter_metadata_service.dart';
import '../windows/parameter_editor.dart';

class ParameterTile extends StatelessWidget {
  final MavParameter parameter;
  final VoidCallback? onTap;

  const ParameterTile({
    super.key,
    required this.parameter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = ParameterMetadataService.get(parameter.name);
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InkWell(
          onTap: onTap,
          child: Tooltip(
            waitDuration: const Duration(seconds: 1),
            showDuration: const Duration(seconds: 8),
            preferBelow: false,
            richMessage: _buildTooltip(metadata),
            child: Row(
              children: [
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    parameter.name,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    parameter.value.toString(),
                    textAlign: TextAlign.end,
                  ),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InlineSpan _buildTooltip(ParameterMetadata? metadata) {
    if (metadata == null) {
      return const TextSpan(text: "No description available.");
    }

    return WidgetSpan(
      child: SizedBox(
        width: 420,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: "${metadata.name}    ( ${metadata.humanName} )",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: "\n\n"),
              TextSpan(text: metadata.description),
              if (metadata.range != null)
                TextSpan(
                  text: "\n\nRange: ${metadata.range}",
                ),
              if (metadata.units != null)
                TextSpan(text: "\n\nUnits: ${metadata.unitText}"),
              TextSpan(
                text:
                    "\n\n${metadata.values!.entries.map((e) => "${e.key}: ${e.value}").join(",\t")}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
