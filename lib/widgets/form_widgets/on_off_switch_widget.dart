import 'package:flutter/material.dart';

class OnOffSwitch extends StatefulWidget {
  const OnOffSwitch({
    required this.value,
    required this.onChanged,
    required this.title,
    this.icon
  });

  final bool? value;
  final Function onChanged;
  final String title;
  final Icon? icon;

  @override
  _OnOffSwitchState createState() => _OnOffSwitchState();
}

class _OnOffSwitchState extends State<OnOffSwitch> {
  bool? optionValue;

  @override
  void initState() { 
    super.initState();
    optionValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeTrackColor: Colors.cyan,
      inactiveTrackColor: Colors.red,
      inactiveThumbColor: Colors.red,
      activeColor: Colors.cyan,
      value: optionValue!,
      title: Center(child: Text(widget.title)),
      secondary: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: kMinInteractiveDimension - 8,
          minHeight: kMinInteractiveDimension,
        ),
        alignment: Alignment.centerLeft,
        icon: widget.icon!,
        onPressed: null,
      ),
      onChanged: (value) => setState((){
        optionValue = value;
        widget.onChanged(value);
      })
    );
  }
}