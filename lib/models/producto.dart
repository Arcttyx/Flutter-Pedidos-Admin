import 'dart:convert';

class Producto {
    String? id;
    String? nombre;
    String? categoria;
    String? descripcion;
    double? precioPorK;
    double? precioPorMedio;
    double? precioPorCuarto;
    double? precioPorUnidad;
    List<String>? categoriasUnidades;
    String? surtidor;
    bool? disponible;
    DateTime? ultimaActualizacion;
    bool? eliminado;

    Producto({
      this.id,
      this.categoria,
      this.nombre,
      this.descripcion,
      this.precioPorK,
      this.precioPorMedio,
      this.precioPorCuarto,
      this.precioPorUnidad,
      this.categoriasUnidades,
      this.surtidor,
      this.disponible = true,
      this.ultimaActualizacion,
      this.eliminado = false
    }) {
      if (this.categoriasUnidades == null) {
        this.categoriasUnidades = [];
      }
    }

    //Usado para desconvertir de Firestore
    factory Producto.fromJson(Map<String, dynamic> json, String id) {
      //categorias de unidades es una subestructura de Strings en firebase dentro del product
      List<String> listacategoriasUnidades = [];
      if ( json["categorias_unidades"] != null ) {
        json["categorias_unidades"].forEach((v) => listacategoriasUnidades.add(v));
      }

      return Producto(
        id                   : id,
        categoria            : json["categoria"],
        nombre               : json["nombre"],
        descripcion          : json["descripcion"],
        precioPorK           : json["precio_kilo"],
        precioPorMedio       : json["precio_medio"],
        precioPorCuarto      : json["precio_cuarto"],
        precioPorUnidad      : json["precio_unidad"],
        surtidor             : json["surtidor"],
        categoriasUnidades   : listacategoriasUnidades,
        disponible           : json["disponible"],
        ultimaActualizacion  : json["ultima_actualizacion"] == null? null : json["ultima_actualizacion"].toDate(),
        eliminado            : json["eliminado"] == null ? false : json["eliminado"],
      );
    }

    //Usado para desconvertir de SQLite
    factory Producto.fromDBJson(Map<String, dynamic> dbEntry) {
      //categorias de unidades es un String json dentro del product
      List<String> listacategoriasUnidades = [];
      if ( dbEntry["categorias_unidades"] != null ) {
        jsonDecode(dbEntry["categorias_unidades"]).forEach((v) => listacategoriasUnidades.add(v));
      }

      //https://stackoverflow.com/questions/56112105/how-to-save-dateformat-with-sharedpreferences-in-flutter
      //ISO 8601 String --> DateTime:     DateTime dateTime = DateTime.parse('2020-04-17T11:59:46.405');
      return Producto(
        id                   : dbEntry["id"],
        categoria            : dbEntry["categoria"],
        nombre               : dbEntry["nombre"],
        descripcion          : dbEntry["descripcion"],
        precioPorK           : dbEntry["precio_kilo"],
        precioPorUnidad      : dbEntry["precio_unidad"],
        categoriasUnidades   : listacategoriasUnidades,
        disponible           : (dbEntry["disponible"] == null)? true : (dbEntry["disponible"] == 1)? true : false,
        ultimaActualizacion  : dbEntry["ultima_actualizacion"] == null? null : DateTime.parse(dbEntry["ultima_actualizacion"]),
        eliminado            : (dbEntry["eliminado"] == null)? false : (dbEntry["eliminado"] == 1)? true : false,
      );
    }

    //Usado para guardar en FIrestore
    Map<String, dynamic> toJson() => {
      "id"                     : id,
      "categoria"              : categoria,
      "nombre"                 : nombre,
      "descripcion"            : descripcion,
      "precio_kilo"            : precioPorK,
      "precio_medio"           : precioPorMedio,
      "precio_cuarto"          : precioPorCuarto,
      "precio_unidad"          : precioPorUnidad,
      "surtidor"               : surtidor,
      "categorias_unidades"    : categoriasUnidades,
      "disponible"             : disponible,
      "ultima_actualizacion"   : ultimaActualizacion,
      "eliminado"              : eliminado
    };

    //Usado para guardar en SQLite
    //https://stackoverflow.com/questions/56112105/how-to-save-dateformat-with-sharedpreferences-in-flutter
    //DateTime --> ISO 8601 String:     String timeStamp = DateTime.now().toIso8601String();
    //ISO 8601 String --> DateTime:     DateTime dateTime = DateTime.parse('2020-04-17T11:59:46.405');
    //2020-04-17T11:59:46.405  // dateTime.toIso8601String()
    //2020-04-17 11:59:46.405  // dateTime.toString()
    Map<String, dynamic> toDBJson() => {
      "id"                     : id,
      "categoria"              : categoria,
      "nombre"                 : nombre,
      "descripcion"            : descripcion,
      "precio_kilo"            : precioPorK,
      "precio_unidad"          : precioPorUnidad,
      "categorias_unidades"    : jsonEncode(categoriasUnidades),
      "disponible"             : (disponible == null)? 1 : (disponible! == true)? 1 : 0,
      "ultima_actualizacion"   : (ultimaActualizacion == null)? null : ultimaActualizacion!.toIso8601String(),
      "eliminado"              : (eliminado == null)? 0 : (eliminado! == true)? 1 : 0,
    };

    @override
    String toString() {
      return toJson().toString();
    }
}