import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/pedido.dart';
import 'package:mercadito_a_distancia/models/producto.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';
import 'package:mercadito_a_distancia/models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../share_prefs/preferencias.dart';
import 'firestore_service.dart';
import 'database_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

/*
This is the main class access/call for any UI widgets that require to perform
any CRUD activities operation in Firestore database.
This class work hand-in-hand with FirestoreService and FirestorePath.

Notes:
For cases where you need to have a special method such as bulk update specifically
on a field, then is ok to use custom code and write it here. For example,
setAllPedidoComplete is require to change all pedidos item to have the complete status
changed to true.

*/
class DataRepository {

  // static final instance = DataRepository._();
  // DataRepository._();

  final _firestoreService = FirestoreService.instance;
  final _databaseService = DatabaseService.instance;

  DataRepository() {
    print('Constructor de Repositorio');
    initRepo();
  }

  void initRepo() async {
    //Se crea la BD solo si no ya está creada
    print('InitRepository');
    await _databaseService.init();
  }

  ///////////////////////////////////////////////////////////
  //------------------PEDIDOS SOLICITADOS------------------//
  ///////////////////////////////////////////////////////////
  //Method to retrieve all pedidos item from the DB
  // Stream<List<Pedido>> pedidosListStream() => _firestoreService.collectionListStream(
  //   collection: kPedidosCollection,
  //   builder: (data, documentId) => Pedido.fromJson(data!, documentId),
  //   sort: (a, b) => a.fechaPedido!.compareTo(b.fechaPedido!),
  //   queryBuilder: (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPedidos))
  // );

  // //Para poder escuchar los últimos cambios, pasará a reemplazar el método pedidosListStream
  // Stream<QuerySnapshot> pedidosStream() => _firestoreService.getCollectionStream(
  //   collection: kPedidosCollection,
  //   queryBuilder: (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPedidos))
  // );

  // ///Bring a List of Pedidos from Firebase
  // Future<List<Pedido>> getPedidosList({int sort(Pedido lhs, Pedido rhs)?, bool isForSync = false}) => _firestoreService.getCollectionList(
  //   collection: kPedidosCollection,
  //   builder: (data, documentId) => Pedido.fromJson(data!, documentId),
  //   sort: sort?? (a, b) => a.fechaPedido!.compareTo(b.fechaPedido!),
  //   queryBuilder: (isForSync)? (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPedidos)) : null
  // );

  // //Method to create Pedido in Firestore
  // Future<bool> addPedido(Pedido pedido) async => await _firestoreService.addData(
  //   collection: kPedidosCollection,
  //   data: pedido.toJson(),
  // );

  // //Method to edit Pedido in Firestore
  // Future<bool> editPedido(Pedido pedido) async => await _firestoreService.editData(
  //   collection: kPedidosCollection,
  //   data: pedido.toJson(),
  //   docId: pedido.id
  // );

  // //Method to delete Pedido in Firestore
  // Future<void> deletePedido(Pedido pedido) async => await _firestoreService.deleteData(
  //   collection: kPedidosCollection,
  //   docId: pedido.id
  // );

  //////SQLITE//////
  //Method to return a List of Pedidos from sqlite DB
  Future<List<Pedido>> getPedidosDBLocalList() async {
    return await _databaseService.getAllEntries(
      table: tablaPedidos,
      builder: (dbEntry) => Pedido.fromDBJson(dbEntry!),
      sort: (a, b) => a.fechaPedido!.compareTo(b.fechaPedido!),
    );
  }

  //Method to return a Last inserted Punto de venta from sqlite DB
  Future<Pedido?> getLastInsertedPedidoDBLocal() async {
    List<Pedido> pedidos = await _databaseService.getAllEntries(
      table: tablaPuntos,
      builder: (dbEntry) => Pedido.fromDBJson(dbEntry!),
      limitCondition: 1,
      sort: (a, b) => int.parse(b.id!).compareTo(int.parse(a.id!)),
    );

    return (pedidos.isEmpty)? null : pedidos.first;
  }

  //Method to bulk insert/update List of objects into sqlite
  Future<bool> upsertPedidos(List<Pedido> pedidos) async => await _databaseService.upsertBulk(
    table: tablaPedidos,
    objectsList: pedidos,
    builder: (Pedido pedido) {
      return pedido.toDBJson();
    }
  );

  //Función usada pra el listener del Stream de Firebase que avisa de los nuevos documentos, actualizaciones y eliminaciones en tiempo real
  // Future<bool> syncAndUpdateNewCloudPedidosToLocalDB(querySnapShot, Function afterUpdateIfResults) async {
  //   print('EN EL LISTENER DE PEDIDOS FIRESTORE');
  //   print("Documentos Nuevos/Actualizados/Eiminados: ${querySnapShot.docChanges.length}");

  //   List<Pedido> pedidosNuevosYActualizados = [];
  //   DateTime? ultimaFecha;
  //   querySnapShot.docChanges.forEach((documentChange){
  //     Pedido nuevoPedido = Pedido.fromJson(documentChange.doc.data()!, documentChange.doc.id);
  //     pedidosNuevosYActualizados.add(nuevoPedido);
  //     if (ultimaFecha == null || (nuevoPedido.ultimaActualizacion!.isAfter(ultimaFecha!)) ) {
  //       ultimaFecha = nuevoPedido.ultimaActualizacion!;
  //     }
  //   });
  //   if (querySnapShot.docChanges.isNotEmpty && pedidosNuevosYActualizados.isNotEmpty) {
  //     bool resultUpsert = await upsertPedidos(pedidosNuevosYActualizados);
  //     if (resultUpsert) {
  //       Preferencias.instance.fechaUltimaConsultaTablaPedidos = (ultimaFecha!.toIso8601String());
  //       //Funcion particular ejecutada despues del upsert y solosi hubo cambios
  //       afterUpdateIfResults();
  //     }
  //     return resultUpsert;
  //   } else {
  //     return true;
  //   }
  // }

  ///////////////////////////////////////////////////////////
  //-----------------CATÁLOGO DE PRODUCTOS-----------------//
  ///////////////////////////////////////////////////////////
  //Method to retrieve all productos item from the DB
  //Para mostrar la lista de productos directamente desde firestore
  // Stream<List<Producto>> productosListStream() => _firestoreService.collectionListStream(
  //   collection: kProductosCollection,
  //   builder: (data, documentId) => Producto.fromJson(data!, documentId),
  //   sort: (a, b) => a.nombre!.compareTo(b.nombre!),
  //   queryBuilder: (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaProductos))
  // );

  // //Para poder escuchar los últimos cambios, pasará a reemplazar el método productosListStream
  // Stream<QuerySnapshot> productosStream() {
  //   print('En el método del stream de productos: ${Preferencias.instance.fechaUltimaConsultaTablaProductos}');
  //   return _firestoreService.getCollectionStream(
  //     collection: kProductosCollection,
  //     queryBuilder: (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaProductos))
  //   );
  // }

  // //Method to bring a List of Products
  // Future<List<Producto>> getProductosList({int sort(Producto lhs, Producto rhs)?, bool isForSync = false}) => _firestoreService.getCollectionList(
  //   collection: kProductosCollection,
  //   builder: (data, documentId) => Producto.fromJson(data!, documentId),
  //   sort: sort?? (a, b) => a.nombre!.compareTo(b.nombre!),
  //   queryBuilder: (isForSync)? (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaProductos)) : null
  // );

  // //Method to create Producto in Firestore
  // Future<bool> addProducto(Producto producto) async => await _firestoreService.addData(
  //   collection: kProductosCollection,
  //   data: producto.toJson(),
  // );

  // //Method to edit Producto in Firestore
  // Future<bool> editProducto(Producto producto) async => await _firestoreService.editData(
  //   collection: kProductosCollection,
  //   data: producto.toJson(),
  //   docId: producto.id
  // );

  // //Method to delete Producto in Firestore
  // Future<void> deleteProducto(Producto producto) async => await _firestoreService.deleteData(
  //   collection: kProductosCollection,
  //   docId: producto.id
  // );

  //////SQLITE//////
  //Method to return a List of Products from sqlite DB
  Future<List<Producto>> getProductosDBLocalList() async {
    //print('Yendo por productos a la BD local');
    return await _databaseService.getAllEntries(
      table: tablaProductos,
      builder: (dbEntry) => Producto.fromDBJson(dbEntry!),
      sort: (a, b) => a.nombre!.compareTo(b.nombre!),
    );
  }

  //Method to return a Last inserted Product from sqlite DB
  Future<Producto?> getLastInsertedProductoDBLocal() async {
    List<Producto> productos = await _databaseService.getAllEntries(
      table: tablaProductos,
      builder: (dbEntry) => Producto.fromDBJson(dbEntry!),
      limitCondition: 1,
      sort: (a, b) => int.parse(b.id!).compareTo(int.parse(a.id!)),
    );

    return (productos.isEmpty)? null : productos.first;
  }

  //Method to bulk insert/update List of objects into sqlite
  Future<bool> upsertProductos(List<Producto> productos) async => await _databaseService.upsertBulk(
    table: tablaProductos,
    objectsList: productos,
    builder: (Producto producto) {
      return producto.toDBJson();
    }
  );

  //Función usada pra el listener del Stream de Firebase que avisa de los nuevos documentos, actualizaciones y eliminaciones en tiempo real
  //Todos los cambios se toman por inserciones o actualizaciones
  //La eliminación se hace lógica porque no se puede sincronizar las Bd's locales ya que al momento de consultar
  //si un usuario esta offline no recibirá esa notificación y solo le llegarán los nuevos docs y los actualizados
  //https://stackoverflow.com/questions/54041748/view-changes-between-snapshots-firestore-flutter
  //https://stackoverflow.com/questions/53982928/flutter-firestore-how-to-listen-for-changes-to-one-document
  //https://flutterforum.co/t/listen-to-changes-in-firestore/1924/4
  //https://www.woolha.com/tutorials/flutter-using-streamcontroller-and-streamsubscription
  // Future<bool> syncAndUpdateNewCloudProductosToLocalDB(querySnapShot, Function afterUpdateIfResults) async {
  //   print('EN EL LISTENER DE PRODUCTOS FIRESTORE');
  //   print("Documentos Nuevos/Actualizados/Eiminados: ${querySnapShot.docChanges.length}");

  //   List<Producto> productosNuevosYActualizados = [];
  //   DateTime? ultimaFecha;
  //   querySnapShot.docChanges.forEach((documentChange){
  //     Producto nuevoProducto = Producto.fromJson(documentChange.doc.data()!, documentChange.doc.id);
  //     productosNuevosYActualizados.add(nuevoProducto);
  //     if (ultimaFecha == null || (nuevoProducto.ultimaActualizacion!.isAfter(ultimaFecha!)) ) {
  //       ultimaFecha = nuevoProducto.ultimaActualizacion!;
  //     }
  //     //print('Ultima fecha:  $ultimaFecha');
  //     // if (documentChange.type == DocumentChangeType.added){
  //     //   //print("document: ${documentChange.doc.data()}, id: ${documentChange.doc.id} added");
  //     //   repositorio.addLocalDBProducto(Producto.fromJson(documentChange.doc.data()!, documentChange.doc.id));
  //     // } else if (documentChange.type == DocumentChangeType.modified){
  //     //   //print("document: ${documentChange.doc.data()}, id: ${documentChange.doc.id} modified");
  //     //   repositorio.updateLocalDBProducto(Producto.fromJson(documentChange.doc.data()!, documentChange.doc.id));
  //     // } else if (documentChange.type == DocumentChangeType.removed){
  //     //   //print("document: ${documentChange.doc.data()}, id: ${documentChange.doc.id} removed");
  //     //   repositorio.deleteLocalDBProducto(Producto.fromJson(documentChange.doc.data()!, documentChange.doc.id));
  //     // }
  //   });
  //   if (querySnapShot.docChanges.isNotEmpty && productosNuevosYActualizados.isNotEmpty) {
  //     print('Productos al upsert: ${productosNuevosYActualizados.length}');
  //     print(productosNuevosYActualizados);
  //     bool resultUpsert = await upsertProductos(productosNuevosYActualizados);
  //     if (resultUpsert) {
  //       Preferencias.instance.fechaUltimaConsultaTablaProductos = (ultimaFecha!.toIso8601String());
  //       print('Nueva Fecha de última consulta a tabla productos:   ${DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaProductos)}');
  //       //Funcion particular ejecutada despues del upsert y solosi hubo cambios
  //       afterUpdateIfResults();
  //     }
  //     return resultUpsert;
  //   } else {
  //     return true;
  //   }
  // }

  //Method to create Producto in SQLite
  Future<int> addLocalDBProducto(Producto producto) async => await _databaseService.insert(
    table: tablaProductos,
    data: producto.toDBJson()
  );

  //Method to create Producto in SQLite
  Future<int> updateLocalDBProducto(Producto producto) async => await _databaseService.update(
    table: tablaProductos,
    data: producto.toDBJson(),
    id: producto.id!
  );

  //Method to create Producto in SQLite
  Future<int> deleteLocalDBProducto(Producto producto) async => await _databaseService.delete(
    table: tablaProductos,
    id: producto.id!
  );

  ///////////////////////////////////////////////////////////
  //-------------------PUNTOS DE ENTREGA-------------------//
  ///////////////////////////////////////////////////////////
  //Method to retrieve all puntos item from the DB
  //Para mostrar la lista de puntos de venta directamente desde firestore
  // Stream<List<PuntoVenta>> puntosListStream() => _firestoreService.collectionListStream(
  //   collection: kPuntosCollection,
  //   builder: (data, documentId) => PuntoVenta.fromJson(data!, documentId),
  //   sort: (a, b) => a.nombre!.compareTo(b.nombre!),
  //   queryBuilder: (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPuntos))
  // );

  // //Para poder escuchar los últimos cambios, pasará a reemplazar el método productosListStream
  // Stream<QuerySnapshot> puntosVentaStream() {
  //   print('En el método del escucha: ${Preferencias.instance.fechaUltimaConsultaTablaPuntos}');
  //   return _firestoreService.getCollectionStream(
  //     collection: kPuntosCollection,
  //     queryBuilder: (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPuntos))
  //   );
  // }

  // //Method to retrieve all puntos collection in List form
  // Future<List<PuntoVenta>> getPuntosList({int sort(PuntoVenta lhs, PuntoVenta rhs)?, bool isForSync = false}) => _firestoreService.getCollectionList(
  //   collection: kPuntosCollection,
  //   builder: (data, documentId) => PuntoVenta.fromJson(data!, documentId),
  //   sort: sort?? (a, b) => a.nombre!.compareTo(b.nombre!),
  //   queryBuilder: (isForSync)? (query) => query.where('ultima_actualizacion', isGreaterThan: DateTime.parse(Preferencias.instance.fechaUltimaConsultaTablaPuntos)) : null
  // );

  // //Method to create punto
  // Future<bool> addPunto(PuntoVenta punto) async => await _firestoreService.addData(
  //   collection: kPuntosCollection,
  //   data: punto.toJson(),
  //   insertId: true
  // );

  // //Method to edit punto
  // Future<bool> editPunto(PuntoVenta punto) async => await _firestoreService.editData(
  //   collection: kPuntosCollection,
  //   data: punto.toJson(),
  //   docId: punto.id
  // );

  // //Method to delete punto entry
  // Future<void> deletePunto(PuntoVenta punto) async => await _firestoreService.deleteData(
  //   collection: kPuntosCollection,
  //   docId: punto.id
  // );

  //Method to delete punto entry from database only
  Future<void> deletePuntoFromDB(PuntoVenta punto) async => await _databaseService.delete(
    table: tablaPuntos,
    id: punto.id!
  );

  Future<void> deleteMultiplePuntosFromDB(List<String> puntos) async => await _databaseService.deleteBulk(
    table: tablaPuntos,
    ids: puntos
  );

  //////SQLITE//////
  //Method to return a List of Puntos de venta from sqlite DB
  Future<List<PuntoVenta>> getPuntosVentaDBLocalList() async {
    //print('Yendo por puntos de venta a la BD local');
    return await _databaseService.getAllEntries(
      table: tablaPuntos,
      builder: (dbEntry) => PuntoVenta.fromDBJson(dbEntry!),
      sort: (a, b) => a.nombre!.compareTo(b.nombre!),
    );
  }

  //Method to return a Last inserted Punto de venta from sqlite DB
  Future<PuntoVenta?> getLastInsertedPuntoVentaDBLocal() async {
    //print('Yendo por puntos de venta a la BD local');
    List<PuntoVenta> puntos = await _databaseService.getAllEntries(
      table: tablaPuntos,
      builder: (dbEntry) => PuntoVenta.fromDBJson(dbEntry!),
      limitCondition: 1,
      sort: (a, b) => int.parse(b.id!).compareTo(int.parse(a.id!)),
    );

    return (puntos.isEmpty)? null : puntos.first;
  }

  //Method to bulk insert/update List of objects into sqlite
  Future<bool> upsertPuntosVenta(List<PuntoVenta> puntos) async => await _databaseService.upsertBulk(
    table: tablaPuntos,
    objectsList: puntos,
    builder: (PuntoVenta punto) {
      return punto.toDBJson();
    }
  );

  //Función usada pra el listener del Stream de Firebase que avisa de los nuevos documentos, actualizaciones y eliminaciones en tiempo real
  // Future<bool> syncAndUpdateNewCloudPuntosVentaToLocalDB(querySnapShot, Function afterUpdateIfResults) async {
  //   print('EN EL LISTENER DE PUNTOS FIRESTORE');
  //   print("Documentos Nuevos/Actualizados/Eiminados: ${querySnapShot.docChanges.length}");

  //   List<PuntoVenta> puntosNuevosYActualizados = [];
  //   DateTime? ultimaFecha;
  //   querySnapShot.docChanges.forEach((documentChange){
  //     PuntoVenta nuevoPuntoVenta = PuntoVenta.fromJson(documentChange.doc.data()!, documentChange.doc.id);
  //     puntosNuevosYActualizados.add(nuevoPuntoVenta);
  //     if (ultimaFecha == null || (nuevoPuntoVenta.ultimaActualizacion!.isAfter(ultimaFecha!)) ) {
  //       ultimaFecha = nuevoPuntoVenta.ultimaActualizacion!;
  //     }
  //   });
  //   if (querySnapShot.docChanges.isNotEmpty && puntosNuevosYActualizados.isNotEmpty) {
  //     bool resultUpsert = await upsertPuntosVenta(puntosNuevosYActualizados);
  //     if (resultUpsert) {
  //       Preferencias.instance.fechaUltimaConsultaTablaPuntos = (ultimaFecha!.toIso8601String());
  //       //Funcion particular ejecutada despues del upsert y solo si hubo cambios
  //       afterUpdateIfResults();
  //     }
  //     return resultUpsert;
  //   } else {
  //     return true;
  //   }
  // }

  ///////////////////////////////////////////////////////////
  //-------------------USUARIOS SISTEMA -------------------//
  ///////////////////////////////////////////////////////////
  //Method to retrieve all puntos item from the DB
  Stream<List<Usuario>> usuariosListStream() => _firestoreService.collectionListStream(
    collection: kUsersCollection,
    builder: (data, documentId) => Usuario.fromJson(data!, documentId),
  );

  Future<Usuario> searchUsuarioById(String id) async {
    DocumentSnapshot document = await _firestoreService.getByDocId(collection: kUsersCollection, docId: id);
    return Usuario.fromJson(document.data()!, document.id);
  }

  //Method to edit my own user
  Future<bool> editUsuario(Usuario? usuario) async {
    final _auth = auth.FirebaseAuth.instance;

    if(_auth.currentUser == null || usuario!.idAuth != _auth.currentUser!.uid) {
      return false;
    }

    //Solo si me estoy editando a mi mismo, actualizo el valor en el provider
    return await _firestoreService.editData(
      collection: kUsersCollection,
      data: usuario.toJson(),
      docId: usuario.idDoc
    );
  }

  // Usuario _getUsuarioFromDocument(DocumentSnapshot snapshot) {
  //   return Usuario.fromJson(snapshot.data());
  // }
}
