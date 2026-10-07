// import 'package:flutter/material.dart';

// class TelemetryPage extends StatelessWidget {
//   const TelemetryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text("Vehicle Page"));
//   }
// }

import 'package:flutter/material.dart';
import '../../../data/app_data.dart';

class TelemetryPage extends StatelessWidget {
  const TelemetryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JetsonTelemetry>(
      valueListenable: AppData.jetsonTelemetry,
      builder: (context, telemetry, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                'Jetson',
                Icons.memory,
              ),
              const SizedBox(height: 12),

              _buildStatusCard(
                context,
                telemetry,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildTemperatureCard(
                      context,
                      title: 'CPU',
                      temperature: telemetry.cpuTemp,
                      icon: Icons.developer_board,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTemperatureCard(
                      context,
                      title: 'GPU',
                      temperature: telemetry.gpuTemp,
                      icon: Icons.graphic_eq,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTemperatureCard(
                      context,
                      title: 'Junction',
                      temperature: telemetry.junctionTemp,
                      icon: Icons.thermostat,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    JetsonTelemetry telemetry,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              telemetry.connected
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              telemetry.connected
                  ? 'Connected'
                  : 'Disconnected',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard(
    BuildContext context, {
    required String title,
    required double temperature,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${temperature.toStringAsFixed(1)} °C',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}