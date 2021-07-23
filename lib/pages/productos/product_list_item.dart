import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/models/producto.dart';

class ProductItem extends StatelessWidget {

  ProductItem({required this.item, this.onTap, this.isMe, this.usersData, this.itemForList = true});

  final Producto item;
  final bool? isMe;
  final Map<String, dynamic>? usersData;
  final bool itemForList;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (item.disponible! || item.disponible == null)? null : Colors.blueGrey[300],
      child: ListTile(
        leading: (itemForList)? Icon(Icons.shopping_basket) : null,
        title: Text(item.nombre?? 'Sin nombre'),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.categoria?? ''),
            Text((usersData != null && item.surtidor != null && usersData!.containsKey(item.surtidor))? usersData![item.surtidor!].nombre : '')
          ],
        ),
        trailing: (itemForList)? crearPrecios(item) : null,
        onTap: onTap?? null
      )
    );
  }

  Widget crearPrecios(Producto item) {
    List<Text> precios = [];

    if (item.precioPorUnidad != null) {
      precios.add(Text('Unidad:  \$${item.precioPorUnidad}'));
    } else {
      if (item.precioPorK != null) {
        precios.add(Text('Kilo:  \$${item.precioPorK}'));
      }
      // if (item.precioPorMedio != null) {
      //   precios.add(Text('1/2:  \$${item.precioPorMedio}'));
      // }
      // if (item.precioPorCuarto != null) {
      //   precios.add(Text('1/4:  \$${item.precioPorCuarto}'));
      // }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: precios,
    );
  }
}