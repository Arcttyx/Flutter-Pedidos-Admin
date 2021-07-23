import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/pages/home_page.dart';
import 'package:mercadito_a_distancia/pages/productos/product_list_page.dart';
import 'package:mercadito_a_distancia/pages/puntos_venta/punto_list_page.dart';

class MenuWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final String? currentRoute = getCurrentRouteName(context);

    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(  //Para poder hacer scroll
          padding: EdgeInsets.zero, //Para no dejar espacios arriba del menú
          children: <Widget>[
            DrawerHeader(
              child: Container(),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/resumen-venta3.jpg'),
                  fit: BoxFit.cover
                )
              ),
            ),
            ListTile(
              leading: Icon(Icons.pages, color: Theme.of(context).primaryColor),
              title: Text('INICIO', style: TextStyle(color: Theme.of(context).primaryColor)),
              selected: currentRoute == HomePage.id,
              onTap: () => (currentRoute == HomePage.id)? Navigator.pop(context) : Navigator.popAndPushNamed(context, HomePage.id), //Si estamos en la misma pantalla que la opción, solo cierra el Drawer, si no, navega a la pantalla deseada
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.list, color: Theme.of(context).primaryColor),
              title: Text('Productos', style: TextStyle(color: Theme.of(context).primaryColor)),
              selected: currentRoute == ProductListPage.id,
              onTap: () => (currentRoute == ProductListPage.id)? Navigator.pop(context) : Navigator.popAndPushNamed(context, ProductListPage.id),
            ),
            ListTile(
              leading: Icon(Icons.point_of_sale, color: Theme.of(context).primaryColor),
              title: Text('Puntos de venta', style: TextStyle(color: Theme.of(context).primaryColor)),
              selected: currentRoute == PuntoVentaListPage.id,
              onTap: () => (currentRoute == PuntoVentaListPage.id)? Navigator.pop(context) : Navigator.popAndPushNamed(context, PuntoVentaListPage.id),
            ),
          ],
        )
      )
    );
  }

  //Obtener el nombre de la ruta actual en la que estamos
  String? getCurrentRouteName(context) {
    String? currentRouteName;

    Navigator.popUntil(context, (route) {
      currentRouteName = route.settings.name;
      return true;
    });

    return currentRouteName;
  }
}