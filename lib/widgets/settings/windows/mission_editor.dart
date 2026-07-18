import 'package:flutter/material.dart';

import '../widgets/mission_panel.dart';

class MissionEditor extends StatelessWidget {
  const MissionEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: SizedBox(
        width: 1800,
        height: 1000,
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(),
            Expanded(
              child: Row(
                children: [
                  MissionPanel(),
                  const VerticalDivider(width: 1),
                  _buildMapPanel(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.route),
          const SizedBox(width: 12),
          const Text(
            "Mission Editor",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // Widget _buildMissionPanel(BuildContext context) {
  //   return SizedBox(
  //     width: 300,
  //     child: Column(
  //       children: [
  //         Container(
  //           height: 42,
  //           alignment: Alignment.center,
  //           child: const Text(
  //             "Mission List",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         const Divider(height: 1),
  //         const Expanded(child: Center(child: Text("Mission List"))),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMapPanel(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          "Map Placeholder",
          style: TextStyle(fontSize: 18, color: Colors.white54),
        ),
      ),
      // child: Center(
      //   child: Image.asset(
      //     'assets/cat.gif',
      //     fit: BoxFit.contain,
      //   ),
      // ),
    );
  }
}
