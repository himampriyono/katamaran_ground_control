import 'package:flutter/material.dart';

Future<String?> showJoystickPortSelector(
  BuildContext context, {
  required List<String> ports,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color.fromARGB(255, 119, 119, 119))),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Select Joystick Port",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  shrinkWrap: true,
                  itemCount: ports.length,
                  itemBuilder: (context, index) {
                    final port = ports[index];

                    return Padding(
                      padding: const EdgeInsetsGeometry.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            Navigator.pop(context, port);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF202020)
                              ),
                              borderRadius: BorderRadius.circular(6)
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.usb,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    port,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                // const Icon(icon)
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
