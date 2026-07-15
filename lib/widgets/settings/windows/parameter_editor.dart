import 'package:flutter/material.dart';
import '../../../models/mav_parameter.dart';
import '../../../services/mavlink_service.dart';
import '../../snackbar.dart';
import '../widgets/action_button.dart';

class ParameterEditor extends StatefulWidget {
  final MavParameter parameter;

  const ParameterEditor({super.key, required this.parameter});

  @override
  State<ParameterEditor> createState() => _ParameterManagerState();
}

class _ParameterManagerState extends State<ParameterEditor> {
  late final TextEditingController _valueController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: widget.parameter.value.toString(),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B1D22),
      child: SizedBox(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
              // const Text(
              //   "Parameter Name",
              //   style: TextStyle(fontWeight: FontWeight.w600),
              // ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  // color: const Color(0xFF2A2D34),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.parameter.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Parameter value",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _valueController,
                      textAlign: TextAlign.center,
                      enabled: !_isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter Value",
                        filled: true,
                        fillColor: const Color(0xFF2A2D34),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ActionButton(
                        text: "Cancel",
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ActionButton(
                        text: _isSaving ? "Saving..." : "Save",
                        color: Colors.cyan,
                        onTap: _isSaving ? null : _saveParameters,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveParameters() async {
    final value = double.tryParse(_valueController.text);

    if (value == null) {
      Snackbar.show("Invalid parameter value.");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await MavlinkService.setParameter(widget.parameter, value);

    if (!mounted){
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (success){
      Navigator.pop(context, widget.parameter.name);
    } else{
      Snackbar.show("Failed to update parameter");
    }
  }
}
