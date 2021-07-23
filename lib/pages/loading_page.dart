import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/producto.dart';
import '../models/punto_venta.dart';
import '../models/pedido.dart';
import '../services/data_repository.dart';
import '../share_prefs/preferencias.dart';
import 'home_page.dart';

class LoadingPage extends StatefulWidget {
  static const String id = 'loading_page';

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() { 
    super.initState();

    syncDatabasesData();
  }

  void syncDatabasesData() async {
    //Se inicializan las preferencias de usuario
    await Preferencias.instance.initPrefs();
    final repositorio = Provider.of<DataRepository>(context, listen: false);

    // print('Fecha de última consulta a tabla productos:   ${DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaProductos)}');
    // print('Fecha de última consulta a tabla puntos:   ${DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPuntos)}');
    // print('Fecha de última consulta a tabla pedidos:   ${DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPedidos)}');

    // //Buscar todos los productos de FIRESTORE con fecha de ultima_actualizacion mayor a la fecha de ultima_consulta ordenados por ultima_actualizacion
    // List<Producto> productos = await repositorio.getProductosList(sort: (a, b) => a.ultimaActualizacion!.compareTo(b.ultimaActualizacion!), isForSync: true);
    // // print('productos consultados en FIRESTORE: ${productos.length}');

    // //Buscar todos los puntos de venta desde FIRESTORE con fecha de ultima_actualizacion mayor a la fecha de ultima_consulta ordenados por ultima_actualizacion
    // List<PuntoVenta> puntos = await repositorio.getPuntosList(sort: (a, b) => a.ultimaActualizacion!.compareTo(b.ultimaActualizacion!), isForSync: true);
    // // print('puntos consultados en FIRESTORE: ${puntos.length}');

    // //Buscar todos los pedidos desde FIRESTORE con fecha de ultima_actualizacion mayor a la fecha de ultima_consulta ordenados por ultima_actualizacion
    // List<Pedido> pedidos = await repositorio.getPedidosList(sort: (a, b) => a.ultimaActualizacion!.compareTo(b.ultimaActualizacion!), isForSync: true);
    // // print('pedidos consultados en FIRESTORE: ${pedidos.length}');


    // //Actualizar la fecha de ultima_consulta a la ultima fecha de ultima_actualizacion del registro mas reciente, solo si se registró algún cambio en la BD local
    final productos = List<Producto>.generate(10, (i) => new Producto(id: i.toString(), categoria: categoriasProductos[i], categoriasUnidades: [unidadKilo, unidadEntera], descripcion: 'Descripción $i', disponible: true, eliminado: false, nombre: 'Producto $i', precioPorK: 10.0 * i, precioPorUnidad: 10.0 * i, ultimaActualizacion: DateTime.now()));
    if (productos.length > 0) {
      //Registrarlos/Actualizarlos como registros en sqlite
      await repositorio.upsertProductos(productos);
      print('Productos almacenados en SQLITE: ${(await repositorio.getProductosDBLocalList()).length}');

      Preferencias.instance.fechaUltimaConsultaTablaProductos = (productos[productos.length -1].ultimaActualizacion!.toIso8601String());
      // print('Nueva Fecha de última consulta a tabla productos:   ${DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaProductos)}');
    }

    final puntos = List<PuntoVenta>.generate(10, (i) => new PuntoVenta(nombre: 'Elemento $i', activo: true, direccion: 'Calle $i Col. San Cristobal', contacto: 'Persona $i', eliminado: false, descripcion: 'Lugar estratégico para las actividades del proecto $i', telefono: '5510101055', ultimaActualizacion: DateTime.now(), id: i.toString()));
    if (puntos.length > 0) {
      await repositorio.upsertPuntosVenta(puntos);
      print('Puntos almacenados en SQLITE: ${(await repositorio.getPuntosVentaDBLocalList()).length}');

      Preferencias.instance.fechaUltimaConsultaTablaPuntos = (puntos[puntos.length -1].ultimaActualizacion!.toIso8601String());
      // print('Nueva Fecha de última consulta a tabla puntos:   ${DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPuntos)}');
    }

    // final pedidos = List<Pedido>.generate(10, (i) => new Pedido(id: i.toString(), eliminado: false, estatus: EstatusPedido.recibido, fecha: DateTime.now(), fechaPedido: DateTime.now(), nombreCliente: 'Cliente $i', puntoVenta: 'Elemento $i', ultimaActualizacion: DateTime.now(), ));
    // if (pedidos.length > 0) {
    //   await repositorio.upsertPedidos(pedidos);
    //   print('Pedidos almacenados en SQLITE: ${(await repositorio.getPedidosDBLocalList()).length}');

    //   Preferencias.instance.fechaUltimaConsultaTablaPedidos = (pedidos[pedidos.length -1].ultimaActualizacion!.toIso8601String());
    //   // print('Fecha de última consulta a tabla pedidos:   ${DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPedidos)}');
    // }

    //Redirigir a Home
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(28, 39, 58, 1),
      body: Center(
        child: Image.asset('assets/img/loading.gif'),
      ),
    );
  }
}
