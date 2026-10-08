import 'package:flutter/material.dart';

import '../../../data/app_data.dart';
import '../../../data/mavlink_data.dart';
import '../../../services/notifier_service.dart';

class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JetsonTelemetry>(
      valueListenable: AppData.jetsonTelemetry,
      builder: (context, jetson, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                context,
                title: 'Jetson',
                icon: Icons.memory_rounded,
                trailing: _buildConnectionStatus(
                  context,
                  connected: jetson.connected,
                ),
                child: _buildJetsonContent(context, jetson),
              ),

              const SizedBox(height: 20),

              _buildSectionCard(
                context,
                title: "Flight Controller",
                icon: Icons.memory_rounded,
                child: ValueListenableBuilder<int>(
                  valueListenable: NotifierService.statusTrigger,
                  builder: (context, _, child) {
                    final mcu = MavlinkData.lastMcuStatus;

                    final double? temperature = mcu == null
                        ? null
                        : mcu.mcuTemperature / 100.0;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildTelemetryMetric(
                            label: "MCU TEMP",
                            value: temperature == null
                                ? "--"
                                : "${temperature.toStringAsFixed(1)} °C",
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              ValueListenableBuilder<TorpedoVoltage>(
                valueListenable: MavlinkData.torpedoVoltage,
                builder: (context, voltage, _) {
                  return _buildSectionCard(
                    context,
                    title: 'Torpedo',
                    icon: Icons.bolt_rounded,
                    child: _buildTorpedoContent(context, voltage),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 21),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                if (trailing != null) trailing,
              ],
            ),

            const SizedBox(height: 18),

            child,
          ],
        ),
      ),
    );
  }

  Widget _buildJetsonContent(BuildContext context, JetsonTelemetry telemetry) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 24) / 3;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildMetricTile(
                context,
                label: 'CPU',
                value: telemetry.cpuTemp,
                unit: '°C',
                icon: Icons.memory_rounded,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildMetricTile(
                context,
                label: 'GPU',
                value: telemetry.gpuTemp,
                unit: '°C',
                icon: Icons.graphic_eq_rounded,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildMetricTile(
                context,
                label: 'Junction',
                value: telemetry.junctionTemp,
                unit: '°C',
                icon: Icons.thermostat_rounded,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTorpedoContent(BuildContext context, TorpedoVoltage voltage) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoColumns = constraints.maxWidth >= 500;

        final children = List.generate(4, (index) {
          final torpedoId = 21 + index;

          return _buildTorpedoTile(
            context,
            torpedoId: torpedoId,
            voltage: voltage.get(torpedoId),
          );
        });

        if (!twoColumns) {
          return Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  children[0],
                  const SizedBox(height: 12),
                  children[2],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  children[1],
                  const SizedBox(height: 12),
                  children[3],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required double value,
    required String unit,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(text: value.toStringAsFixed(1)),
                TextSpan(
                  text: ' $unit',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorpedoTile(
    BuildContext context, {
    required int torpedoId,
    required double voltage,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.battery_5_bar_rounded, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'T$torpedoId',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Battery Voltage', style: theme.textTheme.bodySmall),
              ],
            ),
          ),

          Text(
            '${voltage.toStringAsFixed(2)} V',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context, {
    required bool connected,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(connected ? Icons.circle : Icons.circle_outlined, size: 9),
          const SizedBox(width: 6),
          Text(
            connected ? 'Connected' : 'Offline',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTelemetry(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetric({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
