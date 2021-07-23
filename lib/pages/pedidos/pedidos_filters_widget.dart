import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';
import 'package:mercadito_a_distancia/providers/pedidos_filters_provider.dart';
import 'package:mercadito_a_distancia/providers/puntos_venta_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PedidosFiltersWidget extends StatefulWidget {
  @override
  _PedidosFiltersWidgetState createState() => _PedidosFiltersWidgetState();
}

class _PedidosFiltersWidgetState extends State<PedidosFiltersWidget> {

  TextEditingController filtroFechaController = TextEditingController();

  void dispose() {
    print("dispose");
    filtroFechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(  //Para poder hacer scroll
            child: Column(
              children: [
                Text('Filtros', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 30.0)),
                Divider(thickness: 2, color: Theme.of(context).primaryColor),
                _crearFiltroFecha(),
                _crearFiltroEstatus(),
                _crearFiltroPuntoVenta(),
                SizedBox(height: 40.0),
                GestureDetector(
                  child: Text("Limpiar filtros", style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                  onTap: () {
                    setState(() {
                      Provider.of<PedidosFiltersProvider>(context, listen: false).cleanFilters();
                    });
                  }
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearFiltroEstatus() {
    final providerFiltros = Provider.of<PedidosFiltersProvider>(context, listen: false);
    return DropdownButtonFormField<dynamic>(
      value: providerFiltros.estatus,
      decoration: InputDecoration(
        labelText: 'Estatus del pedido',
      ),
      items: EstatusPedido.values.map((estado) {
        return DropdownMenuItem(
          value: estado,
          child: Text('${describeEnum(estado)[0].toUpperCase()}${describeEnum(estado).substring(1).toLowerCase()}'),
        );
      }).toList(),
      onChanged: (valor) => setState((){
        providerFiltros.setFiltroEstatus(valor);
      }),
    );
  }

  Widget _crearFiltroFecha() {
    final providerFiltros = Provider.of<PedidosFiltersProvider>(context, listen: false);
    final DateFormat formatter = DateFormat("d 'de' MMMM, yyyy", 'es_MX');

    if (providerFiltros.fecha != null) {
      filtroFechaController.text = formatter.format(providerFiltros.fecha!);
    } else {
      filtroFechaController.clear();
    }

    return TextFormField(
      controller: filtroFechaController,
      decoration: InputDecoration(
        labelText: 'Fecha del pedido',
        labelStyle: TextStyle(color: Colors.grey[700]),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5)),
        border: UnderlineInputBorder(borderSide: BorderSide(width: 0.7)),
      ),
      readOnly: true,
      onTap: () async {
        DateTime fechaActual = DateTime.now();
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: (providerFiltros.fecha != null)? providerFiltros.fecha! : fechaActual,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 7)),
          //locale: Locale('es', 'MX'),
        );
        if (pickedDate != null && pickedDate != fechaActual) {
          setState(() {
            providerFiltros.setFiltroFecha(pickedDate);
          });
        }
      },
    );
  }

  Widget _crearFiltroPuntoVenta() {
    final repositorio = Provider.of<DataRepository>(context, listen: false);
    final providerFiltros = Provider.of<PedidosFiltersProvider>(context, listen: false);

    return Consumer<PuntosVentaProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<PuntoVenta>>(
          future: repositorio.getPuntosVentaDBLocalList(),
          builder: (context, puntosSnapshot) {
            if (!puntosSnapshot.hasData || puntosSnapshot.hasError) {
              return Center(
                child: (puntosSnapshot.hasError)? Text(sesionNoIniciada) : CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent),
              );
            }

            List puntosData = [];
            for (var punto in puntosSnapshot.data!) {
              puntosData.add({'id': punto.id, 'nombre': punto.nombre});
            }

            return DropdownButtonFormField<dynamic>(
              value: providerFiltros.punto,
              decoration: InputDecoration(
                labelText: 'Punto de venta',
              ),
              items: puntosData.map((punto) {
                return DropdownMenuItem(
                  value: punto['id'],
                  child: Text(punto['nombre']),
                );
              }).toList(),
              onChanged: (valor) => setState((){
                providerFiltros.setFiltroPunto(valor);
              }),
            );
          },
        );
      }
    );
  }
}