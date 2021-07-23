class PuntoVenta {
    String? id;
    String? nombre;
    String? direccion;
    String? descripcion;
    String? contacto;
    String? telefono;
    String? lat;
    String? long;
    bool? activo;
    DateTime? ultimaActualizacion;
    bool? eliminado;

    PuntoVenta({
      this.id,
      this.nombre,
      this.direccion,
      this.descripcion,
      this.contacto,
      this.telefono,
      this.lat,
      this.long,
      this.activo = true,
      this.ultimaActualizacion,
      this.eliminado = false
    });

    //Usado para desconvertir de Firestore
    factory PuntoVenta.fromJson(Map<String, dynamic> json, String id) {
      return PuntoVenta(
        id                   : id,
        nombre               : json["nombre"],
        direccion            : json["direccion"],
        descripcion          : json["descripcion"],
        contacto             : json["contacto"],
        telefono             : json["telefono"],
        lat                  : json["lat"],
        long                 : json["long"],
        activo               : json["activo"],
        ultimaActualizacion  : json["ultima_actualizacion"] == null? null : json["ultima_actualizacion"].toDate(),
        eliminado            : json["eliminado"] == null ? false : json["eliminado"],
      );
    }

    //Usado para desconvertir de SQLite
    factory PuntoVenta.fromDBJson(Map<String, dynamic> dbEntry) {
      //ISO 8601 String --> DateTime:     DateTime dateTime = DateTime.parse('2020-04-17T11:59:46.405');
      return PuntoVenta(
        id                   : dbEntry["id"],
        nombre               : dbEntry["nombre"],
        direccion            : dbEntry["direccion"],
        descripcion          : dbEntry["descripcion"],
        contacto             : dbEntry["contacto"],
        telefono             : dbEntry["telefono"],
        lat                  : dbEntry["lat"],
        long                 : dbEntry["long"],
        activo               : (dbEntry["activo"] == null)? false : (dbEntry["activo"] == 1)? true : false,
        ultimaActualizacion  : dbEntry["ultima_actualizacion"] == null? null : DateTime.parse(dbEntry["ultima_actualizacion"]),
        eliminado            : (dbEntry["eliminado"] == null)? false : (dbEntry["eliminado"] == 1)? true : false,
      );
    }

    //Usado para guardar en FIrestore
    Map<String, dynamic> toJson() => {
      "id"                     : id,
      "nombre"                 : nombre,
      "direccion"              : direccion,
      "descripcion"            : descripcion,
      "contacto"               : contacto,
      "telefono"               : telefono,
      "lat"                    : lat,
      "long"                   : long,
      "activo"                 : activo,
      "ultima_actualizacion"   : ultimaActualizacion,
      "eliminado"              : eliminado
    };

    //Usado para guardar en SQLite
    //ISO 8601 String --> DateTime:     DateTime dateTime = DateTime.parse('2020-04-17T11:59:46.405');
    Map<String, dynamic> toDBJson() => {
      "id"                     : id,
      "nombre"                 : nombre,
      "direccion"              : direccion,
      "descripcion"            : descripcion,
      "contacto"               : contacto,
      "telefono"               : telefono,
      "lat"                    : lat,
      "long"                   : long,
      "activo"                 : (activo == null)? 0 : (activo! == true)? 1 : 0,
      "ultima_actualizacion"   : (ultimaActualizacion == null)? null : ultimaActualizacion!.toIso8601String(),
      "eliminado"              : (eliminado == null)? 0 : (eliminado! == true)? 1 : 0,
    };

    @override
    String toString() {
      return toJson().toString();
    }
}