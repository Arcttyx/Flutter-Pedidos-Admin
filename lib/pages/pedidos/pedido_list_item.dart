import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/pedido.dart';
import 'package:intl/intl.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';

class PedidoItem extends StatelessWidget {

  PedidoItem({required this.item, required this.onTap, this.puntosData});

  final Pedido item;
  final void Function() onTap;

  //Para mostrar el nombre del punto en vez del id
  final Map<String?, PuntoVenta>? puntosData;

  final DateFormat formatter = DateFormat("d 'de' MMMM, yyyy", 'es_MX');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(iconEstatus()),
        title: Text(item.nombreCliente?? 'Sin nombre'),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text((item.fechaPedido == null)? '' : formatter.format(item.fechaPedido!)),
            //Text(item.puntoVenta == null? '' : 'Punto: ${item.puntoVenta}'),
            Text((puntosData != null && item.puntoVenta != null && puntosData!.containsKey(item.puntoVenta))? 'Punto: ${puntosData![item.puntoVenta]!.nombre}' : '')
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('${describeEnum(item.estatus)[0].toUpperCase()}${describeEnum(item.estatus).substring(1).toLowerCase()}',
              style: TextStyle(color: (item.estatus == EstatusPedido.recibido || item.estatus == EstatusPedido.preparado)? null : (item.estatus == EstatusPedido.cancelado)? Colors.red : Colors.green),
            ),
            Text('${item.total}'),
          ],
        ),
        onTap: onTap
      )
    );
  }

  IconData? iconEstatus() {
    IconData? icono;
    switch (describeEnum(item.estatus)) {
      case 'recibido':
        icono = Icons.content_paste_rounded;
        break;
      case 'preparado':
        icono = Icons.shopping_basket_outlined;
        break;
      case 'entregado':
        icono = Icons.check;
        break;
      case 'cancelado':
        icono = Icons.cancel;
        break;
      default:
    }
    return icono;
  }
}