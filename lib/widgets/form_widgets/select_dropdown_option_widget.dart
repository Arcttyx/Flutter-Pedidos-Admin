import 'package:flutter/material.dart';

class SelectDropDownOption extends StatefulWidget {
  const SelectDropDownOption({
    required this.value,
    required this.onChanged,
    required this.options,
    this.optionKeyId,
    this.optionValueId,
    this.disabledOption,
    this.hintText = 'Ingresa un valor',
    this.errorText = 'Ingresa un valor',
    this.isEnabled = true
  });

  final String? value;
  final Function onChanged;
  final String hintText;
  final String errorText;
  final List<dynamic> options;
  final String? disabledOption;
  final String? optionKeyId;
  final String? optionValueId;
  final bool isEnabled;

  @override
  _SelectDropDownOptionState createState() => _SelectDropDownOptionState();
}

class _SelectDropDownOptionState extends State<SelectDropDownOption> {
  String? optionValue;

  @override
  void initState() { 
    super.initState();
    optionValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: optionValue,
      hint: Text(widget.hintText),
      disabledHint: (widget.disabledOption != null)? Text(widget.disabledOption!) : null,
      items: widget.options.map((option) {
        return DropdownMenuItem(
          value: (widget.optionKeyId != null)? option[widget.optionKeyId] : option,
          child: (widget.optionValueId != null)? Text(option[widget.optionValueId]) : Text(option),
        );
      }).toList(),
      onChanged: (widget.isEnabled)? (value) {
        widget.onChanged(value);
        setState((){
          optionValue = value.toString();
        });
      } : null,
      validator: (value) => value == null ? widget.errorText : null,
    );
  }
}