import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/pages/login_page.dart';
import 'package:mercadito_a_distancia/pages/productos/product_list_page.dart';
import 'package:mercadito_a_distancia/pages/puntos_venta/punto_list_page.dart';
import 'package:mercadito_a_distancia/pages/solicitado/solicitado_list_page.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/widgets/bottom_navigation_admin_widget.dart';
import 'package:mercadito_a_distancia/widgets/bottom_navigation_widget.dart';
import 'package:mercadito_a_distancia/widgets/image_card_widget.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mercadito_a_distancia/utils/utils.dart' as utils;
import 'package:mercadito_a_distancia/widgets/menu_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  static const String id = 'home_page';

  final _auth = auth.FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    //auth.User loggedInUser = _auth.currentUser;
    int randomImg = Random().nextInt(3) + 1;

    return WillPopScope(
      onWillPop: () async {
        bool? confirmar = await utils.mostrarConfirmar(context, '¿Salir de la aplicación?', 'Al salir, se cerrará su sesión automáticamente', 'No', 'Si');
        //if (confirmar != null && confirmar) {
        if (confirmar != null && confirmar) {
          _auth.signOut();
          //ToDo: Borrar los datos de los providers también, para que si salen de sesión y entran con otro usuario no vea lo guardado por el previo usuario
          Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.id, (Route<dynamic> route) => false);
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Demo App'),
              //Flexible(child: Text('Hola, ${loggedInUser.displayName}', style: TextStyle(fontSize: 15),)),
              Text('Hola, ${Provider.of<UsuarioProvider>(context).usuario!.nombre}', style: TextStyle(fontSize: 15))
            ],
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  //ToDo: Borrar los datos de los providers también, para que si salen de sesión y entran con otro usuario no vea lo guardado por el previo usuario
                  _auth.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.id, (Route<dynamic> route) => false);
                }
              ),
          ],
        ),
        drawer: MenuWidget(),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 20.0,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ImageCard(img: 'assets/img/mercado$randomImg.jpg', icon: Icons.format_list_bulleted, title: 'Lista de Productos', onTap: () {
                              Navigator.pushNamed(context, ProductListPage.id);
                            },),
                          ),
                          Expanded(
                            child: ImageCard(img: 'assets/img/punto-venta$randomImg.jpg', icon: Icons.point_of_sale_rounded, title: 'Puntos de venta', onTap: () {
                              Navigator.pushNamed(context, PuntoVentaListPage.id);
                            },),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ImageCard(img: 'assets/img/resumen-venta$randomImg.jpg', icon: Icons.content_paste_rounded, title: 'Resumen de ventas',
                        onTap: () {
                          Navigator.pushNamed(context, SolicitadoListPage.id);
                        },
                      )
                    ),
                    SizedBox(height: 100.0),
                  ],
                ),
              ),
              Provider.of<UsuarioProvider>(context).usuario!.rol == rolAdmin? BottomNavAdmin() : BottomNavUser()
            ],
          )
        ),
      ),
    );
  }
}