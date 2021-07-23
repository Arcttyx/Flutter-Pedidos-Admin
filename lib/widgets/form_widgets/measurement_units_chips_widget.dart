import 'package:flutter/material.dart';

class MeasurementUnitsChips extends StatefulWidget {
  const MeasurementUnitsChips({
    required this.isKiloSelected,
    required this.isUnidadSelected,
    required this.onKiloSelected,
    required this.onUnidadSelected,
    required this.textFieldKilo,
    required this.textFieldUnidad
  });

  final bool isKiloSelected;
  final bool isUnidadSelected;
  final Function onKiloSelected;
  final Function onUnidadSelected;
  final TextFormField textFieldKilo;
  final TextFormField textFieldUnidad;

  @override
  _MeasurementUnitsChipsState createState() => _MeasurementUnitsChipsState();
}

class _MeasurementUnitsChipsState extends State<MeasurementUnitsChips> {
  late bool optionKiloSelected;
  late bool optionUnidadSelected;

  @override
  void initState() { 
    super.initState();
    optionKiloSelected = widget.isKiloSelected;
    optionUnidadSelected = widget.isUnidadSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FilterChip(
                label: Text('Kilo'),
                selected: optionKiloSelected,
                onSelected: (bool value) {
                  setState(() {
                    optionKiloSelected = value;
                    if (value) {
                      optionUnidadSelected = false;
                    }
                    widget.onKiloSelected(value);
                  });
                },
                selectedColor: Colors.cyan,
                showCheckmark: true,
                elevation: 5.0,
              ),
            ),
            Expanded(
              child: FilterChip(
                label: Text('Unidad'),
                selected: optionUnidadSelected,
                onSelected: (bool value) {
                  setState(() {
                    optionUnidadSelected = value;
                    if (value) {
                      optionKiloSelected = false;
                    }
                    widget.onUnidadSelected(value);
                  });
                },
                selectedColor: Colors.cyan,
                showCheckmark: true,
                elevation: 5.0,
              ),
            ),
          ],
        ),
        _crearPreciosPorUnidadesMedidas()
      ],
    );
  }

  Widget _crearPreciosPorUnidadesMedidas() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: (optionKiloSelected)? widget.textFieldKilo : Container()),
        Expanded(child: (optionUnidadSelected)? widget.textFieldUnidad : Container()),
      ],
    );
  }
}