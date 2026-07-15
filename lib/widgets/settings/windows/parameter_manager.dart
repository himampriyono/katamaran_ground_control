import 'package:flutter/material.dart';
import '../../../data/mavlink_data.dart';
import '../../../services/mavlink_service.dart';
import '../../../services/notifier_service.dart';
import '../widgets/action_button.dart';
import '../widgets/parameter_tile.dart';
import 'parameter_editor.dart';

class ParameterManager extends StatefulWidget {
  const ParameterManager({super.key});

  @override
  State<ParameterManager> createState() => _ParameterManagerState();
}

class _ParameterManagerState extends State<ParameterManager> {
  final TextEditingController _searchController = TextEditingController();
  String? _message;
  Color _messageColor = Colors.green;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B1D22),
      child: SizedBox(
        width: 700,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Parameter Manager",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Read and configure ship parameters.",
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(height: 5),
              if (_message != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    _message!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              SizedBox(height: 5),
              Row(
                children: [ 
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Search Parameters...",
                          hintStyle: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(Icons.search, size: 18),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.close, size: 18),
                                ),
                          filled: true,
                          fillColor: const Color(0xFF2A2D34),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withAlpha(30),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.cyan),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Spacer(),
                  const SizedBox(width: 32),
                  ValueListenableBuilder(
                    valueListenable: NotifierService.parameterTrigger,
                    builder: (context, _, _) {
                      return ActionButton(
                        color: Colors.cyan,
                        text: MavlinkData.isLoadingParameters
                            ? "Receiving..."
                            : "Refresh",
                        onTap: () {
                          MavlinkData.isLoadingParameters
                              ? null
                              : MavlinkService.requestParameterList();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: NotifierService.parameterTrigger,
                  builder: (context, _, _) {
                    final keyword = _searchController.text.trim().toLowerCase();
                    final parameters = MavlinkData.parameters.values.where((
                      parameter,
                    ) {
                      if (keyword.isEmpty) {
                        return true;
                      }

                      return parameter.name.toLowerCase().contains(keyword);
                    }).toList();

                    parameters.sort((a, b) {
                      return a.name.compareTo(b.name);
                    });

                    if (MavlinkData.isLoadingParameters) {
                      final progress = MavlinkData.parameterCount == 0
                          ? 0.0
                          : MavlinkData.parameterLoaded /
                                MavlinkData.parameterCount;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Receiving parameters..."),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 12),
                          Text(
                            "${MavlinkData.parameterLoaded} / ${MavlinkData.parameterCount}",
                          ),
                        ],
                      );
                    } else if (MavlinkData.parameters.isEmpty) {
                      return Center(child: Text("no Parameters"));
                    } else {
                      return ListView.builder(
                        itemCount: parameters.length,
                        itemBuilder: (context, index) {
                          return ParameterTile(
                            parameter: parameters[index],
                            onTap: () async{
                              final result = await showDialog<String>(
                                context: context,
                                builder: (_) {
                                  return ParameterEditor(
                                    parameter: parameters[index],
                                  );
                                },
                              );
                              

                              if (result != null){
                                showMessage(
                                  'Parameter "$result" updated successfully.'
                                );
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showMessage(String text, {Color color = Colors.green}) {
    setState(() {
      _message = text;
      _messageColor = color;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        _message = null;
      });
    });
  }
}
