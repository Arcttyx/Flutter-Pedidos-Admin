import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectFilter extends StatefulWidget {
  const DateSelectFilter({
    required this.dateValue,
    required this.labelText,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onTap,
    this.onSaved,
    this.isEnabled = true,
    this.isMandatory = false,
    this.errorText = 'Ingrese una fecha'
  });

  final DateTime? dateValue;
  final String labelText;
  final String errorText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime lastDate;
  final Function? onTap;
  final Function? onSaved;
  final bool isEnabled;
  final bool isMandatory;

  @override
  _DateSelectFilterState createState() => _DateSelectFilterState();
}

class _DateSelectFilterState extends State<DateSelectFilter> {
  final TextEditingController _filtroFechaController = TextEditingController();
  final DateFormat formatter = DateFormat("d 'de' MMMM, yyyy", 'es_MX');
  DateTime? initialDate;

  @override
  void initState() { 
    super.initState();

    _filtroFechaController.text = formatter.format(widget.dateValue!);
    initialDate = widget.initialDate;
  }

  void dispose() {
    _filtroFechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _filtroFechaController,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.grey[700]),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5)),
        border: UnderlineInputBorder(borderSide: BorderSide(width: 0.7)),
      ),
      readOnly: true,
      onTap: (widget.isEnabled)? () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate!,
          firstDate: widget.firstDate!,
          lastDate: widget.lastDate,
          //locale: Locale('es', 'MX'),
        );
        if (pickedDate != null) {
          setState(() {
            _filtroFechaController.text = formatter.format(pickedDate);
            initialDate = pickedDate;
          });

          if (widget.onTap != null) {
            //Funcion after tap que devuelve la nueva fecha en DateTime
            widget.onTap!(pickedDate);
          }
        }
      } : null,
      validator: (widget.isMandatory)? (valor) {
        if (valor!.isEmpty) {
          return widget.errorText;
        }
        return null;
      } : null,
      onSaved: (widget.onSaved != null)? (value) {
        //Devolver el valor en DateTime
        widget.onSaved!(DateFormat("d 'de' MMMM, yyyy", 'es_MX').parse(value!));
      } : null
    );
  }
}