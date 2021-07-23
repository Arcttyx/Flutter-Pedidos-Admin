import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';

class PuntoVentaItem extends StatelessWidget {

  PuntoVentaItem({required this.item, this.onTap, this.onLongPress, this.trailing});

  final PuntoVenta item;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.activo!? null : Colors.blueGrey[300],
      child: ListTile(
        leading: Icon(Icons.place),
        title: Text(item.nombre?? 'Sin nombre'),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.direccion?? ''),
          ],
        ),
        trailing: trailing?? null,
        onTap: onTap?? null,
        onLongPress: onLongPress?? null
      )
    );
  }
}