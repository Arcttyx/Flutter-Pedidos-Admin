import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/pages/pedidos/pedidos_list_page.dart';
import 'package:mercadito_a_distancia/pages/productos/product_list_page.dart';
import 'package:mercadito_a_distancia/pages/puntos_venta/punto_list_page.dart';
import 'package:mercadito_a_distancia/pages/users/user_form_page.dart';
import 'package:mercadito_a_distancia/widgets/fab_home.dart';

class BottomNavAdmin extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: size.width,
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(size.width, 80),
              painter: BNBCustomPainter(),
            ),
            Center(
              heightFactor: 0.6,
              child: FABHome()
            ),
            Container(
              width: size.width,
              height: 80,
              child: BottomNavAdminButtoms()
            )
          ],
        ),
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20), radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BottomNavAdminButtoms extends StatefulWidget {

  @override
  _BottomNavAdminButtomsState createState() => _BottomNavAdminButtomsState();
}

class _BottomNavAdminButtomsState extends State<BottomNavAdminButtoms> {
  //final int idxHome = 0;
  final int idxPerfil = 0;
  final int idxProductos = 1;
  final int idxPuntos = 2;
  final int idxPedidos = 3;
  int currentIndex = 0;

  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final String? currentRoute = setCurrentRouteName(context);

    return Container(
       child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: (currentRoute == FormUserPage.id)? null : () {
              setBottomBarIndex(idxPerfil);
              //Navigator.pushNamed(context, FormUserPage.id);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.person, color: currentIndex == idxPerfil ? Theme.of(context).primaryColor : Colors.grey.shade400,),
                Text("Perfil", style: TextStyle(color: currentIndex == idxPerfil ? Theme.of(context).primaryColor : Colors.grey.shade400))
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setBottomBarIndex(idxProductos);
              Navigator.pushNamed(context, ProductListPage.id);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.format_list_bulleted, color: currentIndex == idxProductos ? Theme.of(context).primaryColor : Colors.grey.shade400),
                Text("Productos", style: TextStyle(color: currentIndex == idxProductos ? Theme.of(context).primaryColor : Colors.grey.shade400))
              ],
            ),
          ),
          Container(
            width: size.width * 0.20,
          ),
          GestureDetector(
            onTap: () {
              setBottomBarIndex(idxPuntos);
              Navigator.pushNamed(context, PuntoVentaListPage.id);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.filter_center_focus, color: currentIndex == idxPuntos ? Theme.of(context).primaryColor : Colors.grey.shade400),
                Text("Puntos", style: TextStyle(color: currentIndex == idxPuntos ? Theme.of(context).primaryColor : Colors.grey.shade400))
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setBottomBarIndex(idxPedidos);
              Navigator.pushNamed(context, PedidosListPage.id);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.content_paste, color: currentIndex == idxPedidos ? Theme.of(context).primaryColor : Colors.grey.shade400),
                Text("Pedidos", style: TextStyle(color: currentIndex == idxPedidos ? Theme.of(context).primaryColor : Colors.grey.shade400))
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Obtiene el nombre de la ruta actual en la que estamos y establece el indice inicial
  String? setCurrentRouteName(context) {
    String? currentRouteName = ModalRoute.of(context)!.settings.name;
    switch (currentRouteName) {
      case FormUserPage.id:
        currentIndex = idxPerfil;
        break;
      case ProductListPage.id:
        currentIndex = idxProductos;
        break;
      case PuntoVentaListPage.id:
        currentIndex = idxPuntos;
        break;
      case PedidosListPage.id:
        currentIndex = idxPedidos;
        break;
      default:
    }
    return currentRouteName;
  }
}