import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/pages/pedidos/pedido_admin_page.dart';

class FABHome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        border: new Border.all(
          width: 10,
          color: Theme.of(context).primaryColor.withOpacity(0.6)
        ),
      ),
      child: FloatingActionButton(
        child: Icon(Icons.shopping_cart, size: 30.0,),
        onPressed: () {
          Navigator.pushNamed(context, PedidoAdminPage.id);
        },
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}