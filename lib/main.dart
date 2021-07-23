import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/loading_page.dart';
import 'pages/home_page.dart';
import 'pages/pedidos/pedidos_list_page.dart';
import 'pages/pedidos/pedido_admin_page.dart';
import 'pages/productos/product_list_page.dart';
import 'pages/productos/product_form_page.dart';
import 'pages/puntos_venta/punto_list_page.dart';
import 'pages/puntos_venta/punto_form_page.dart';
import 'pages/solicitado/solicitado_list_page.dart';
import 'pages/users/user_form_page.dart';

import 'services/data_repository.dart';

import 'providers/cart_provider.dart';
import 'providers/pedidos_filters_provider.dart';
import 'providers/usuario_provider.dart';

import 'providers/productos_provider.dart';
import 'providers/pedidos_provider.dart';
import 'providers/puntos_venta_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting('es_MX', null);
  runApp(MercaditoApp());
}

class MercaditoApp extends StatelessWidget {
  final Color primaryColorValue = Color.fromRGBO(223, 50, 131, 1);
  final Color scaffoldBackgroundColorValue = Color.fromRGBO(218, 203, 220, 1);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PedidosFiltersProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),

        ChangeNotifierProvider(create: (_) => ProductosProvider()),
        ChangeNotifierProvider(create: (_) => PuntosVentaProvider()),
        ChangeNotifierProvider(create: (_) => PedidosProvider()),

        Provider<DataRepository>(create: (context) => DataRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: LoginPage.id,
        routes: {
          LoginPage.id: (context) => LoginPage(),
          RegisterPage.id: (context) => RegisterPage(),
          LoadingPage.id: (context) => LoadingPage(),
          HomePage.id: (context) => HomePage(),
          ProductListPage.id: (context) => ProductListPage(),
          PedidosListPage.id: (context) => PedidosListPage(),
          PuntoVentaListPage.id: (context) => PuntoVentaListPage(),
          FormProduct.id: (context) => FormProduct(),
          PedidoAdminPage.id: (context) => PedidoAdminPage(),
          FormPuntoVenta.id: (context) => FormPuntoVenta(),
          SolicitadoListPage.id: (context) => SolicitadoListPage(),
          FormUserPage.id: (context) => FormUserPage(),
        },
        theme: ThemeData(
          primaryColor: primaryColorValue,
          scaffoldBackgroundColor: scaffoldBackgroundColorValue,
          fontFamily: 'Kurale',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: primaryColorValue,
              onPrimary: Colors.white,
              minimumSize: Size(10, 50),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        )
      ),
    );
  }
}