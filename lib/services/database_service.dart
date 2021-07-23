
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//https://steemit.com/programming/@tstieff/using-sqflite-in-your-flutter-applicaiton-effectively
//https://medium.com/flutterdevs/data-persistence-with-sqlite-flutter-47a6f67b973f
//https://itnext.io/how-to-use-flutter-with-sqlite-b6c75a5215c4
//https://www.freecodecamp.org/news/using-streams-blocs-and-sqlite-in-flutter-2e59e1f7cdce/


class DatabaseService{
  DatabaseService._();
  static final instance = DatabaseService._();

  Database? _database;

  Future<void> init() async {
    print('init database service');
    if (_database != null) { return; }

    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String _path = join(directory.path, 'mercadito_database.db');
      //String _path = join(await getDatabasesPath(), 'mercadito_database.db');
      print('Creando la BD');
      _database = await openDatabase(_path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    } catch(ex) { 
      print(ex);
    }
  }

  void _onCreate(Database db, int version) async {
    print('Creando las tablas de la BD');
    //id:                   ID DOCUMENTO FIRESTORE
    //categorias_unidades   JSON CON LA LISTA DE UNIDADES
    //disponible            1 o 0 PARA BOOLEANO
    //ultima_actualizacion  TimeStamp (ISO 8601) COMO STRING
    //eliminado             1 o 0 PARA BOOLEANO
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY NOT NULL,
        nombre TEXT,
        categoria TEXT,
        descripcion TEXT,
        precio_kilo REAL,
        precio_unidad REAL,
        categorias_unidades TEXT,
        disponible INTEGER,
        ultima_actualizacion TEXT,
        eliminado INTEGER
      )
    ''');

    // id;                  ID DOCUMENTO FIRESTORE
    // activo;              1 o 0 PARA BOOLEANO
    // ultimaActualizacion; TimeStamp (ISO 8601) COMO STRING
    // eliminado;           1 o 0 PARA BOOLEANO
    await db.execute('''
      CREATE TABLE puntos(
        id TEXT PRIMARY KEY NOT NULL,
        nombre TEXT,
        direccion TEXT,
        descripcion TEXT,
        contacto TEXT,
        telefono TEXT,
        lat TEXT,
        long TEXT,
        activo INTEGER,
        ultima_actualizacion TEXT,
        eliminado INTEGER
      )
    ''');

    // id:                    ID DOCUMENTO FIRESTORE
    // fecha:                 TimeStamp (ISO 8601) COMO STRING
    // fechaPedido:           TimeStamp (ISO 8601) COMO STRING
    // puntoVenta:            ID DEL DOCUMENTO DEL PUNTO DE VENTA EN FIRESTORE
    // productosPedido:       JSON CON LA LISTA DE PRODUCTOS DEL PEDIDO
    // estatus:               EstatusPedido manejado como TEXT
    // ultimaActualizacion;   TimeStamp (ISO 8601) COMO STRING
    // eliminado;             1 o 0 PARA BOOLEANO
    await db.execute('''
      CREATE TABLE pedidos(
        id TEXT PRIMARY KEY NOT NULL,
        fecha TEXT,
        fecha_pedido TEXT,
        nombre_cliente TEXT,
        punto_venta TEXT,
        total REAL,
        productos_pedido TEXT,
        estatus TEXT,
        ultima_actualizacion TEXT,
        eliminado INTEGER
      )
    ''');
  }

  // UPGRADE DATABASE TABLES
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      //db.execute("ALTER TABLE productos ADD COLUMN newCol TEXT;");
    }
  }

  //return all entries of table from the database
  Future<List<T>> getAllEntries<T>({
    required String table,
    required T builder(Map<String, dynamic>? data),
    String? whereCondition,
    List<Object?>? whereArgsCondition,
    int sort(T lhs, T rhs)?,
    int? limitCondition
  }) async {
    var registros = await _database!.query(table, where: whereCondition, whereArgs: whereArgsCondition);
    List<T> result = registros.map((c) => builder(c)).toList();
    if (sort != null) {
      result.sort(sort);
    }
    if (limitCondition != null) {
      if (result.isNotEmpty && result.length > limitCondition) {
        result = result.take(limitCondition).toList();
      }
    }
    return result;
  }

  Future<int> insert({required String table, required Map<String, dynamic> data}) async =>
      await _database!.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<int> update({required String table, required Map<String, dynamic> data, required String id}) async =>
      await _database!.update(table, data, where: 'id = ?', whereArgs: [id]);

  Future<int> delete({required String table, required String id}) async =>
      await _database!.delete(table, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteBulk({required String table, required List<String> ids}) async =>
    await _database!.delete(table, where: 'id IN (${List.filled(ids.length, '?').join(',')})', whereArgs: ids);

  Future<bool> upsertBulk<T>({required String table, required List<T> objectsList, required Map<String, Object?> builder(T data)}) async {
    try {
      /// Initialize batch
      final batch = _database!.batch();

      /// Batch upsert
      objectsList.forEach((object) {
        //Si ya existe lo reemplaza con la nueva data, si no existe lo inserta
        batch.insert(table, builder(object), conflictAlgorithm: ConflictAlgorithm.replace);
      });

      /// Commit
      await batch.commit(noResult: true);

      return true;
    } on DatabaseException catch (e) {
      print(e);
      return false;
    }
  }
}