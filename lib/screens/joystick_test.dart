import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../utils/joystick.dart';

class JoystickTest extends StatefulWidget {
  const JoystickTest({super.key});

  @override
  State<JoystickTest> createState() => _JoystickTestState();
}

class _JoystickTestState extends State<JoystickTest> {
  List<String> _ports = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("test joystick")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _scanPorts,
                child: Text("Scan Ports"),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: Joystick.startAutoConnectJoystick,
                child: Text("Auto connect"),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: Joystick.disconnect,
                child: Text("Disconnect"),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _ports.length,
                itemBuilder: (context, index) {
                  final port = _ports[index];

                  return Card(
                    child: ListTile(
                      title: Text(port),
                      trailing: Icon(Icons.usb),
                      onTap: () {
                        Joystick.connect(port);
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<int>>(
                valueListenable: AppData.joystickChannels,
                builder: (context, channels, _) {
                  return ListView.builder(
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text("CH${index + 1}"),
                        trailing: Text("${channels[index]}"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanPorts() {
    setState(() {
      _ports = Joystick.scanPort();
    });
  }
}
