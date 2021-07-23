class Usuario {
    String? idAuth;
    String? idDoc;
    String? nombre;
    String? email;
    String? rol;
    bool? activo;

    Usuario({
      this.idAuth,
      this.idDoc,
      this.nombre,
      this.email,
      this.rol,
      this.activo = true,
    });

    factory Usuario.fromJson(Map<String, dynamic> json, String id) {
      return Usuario(
        idAuth               : json["id_auth"],
        idDoc                : id,
        nombre               : json["nombre"],
        email                : json["email"],
        rol                  : json["rol"],
        activo               : json["activo"],
      );
    }

    Map<String, dynamic> toJson() => {
      "id_auth"                : idAuth,
      "id_doc"                 : idDoc,
      "nombre"                 : nombre,
      "email"                  : email,
      "rol"                    : rol,
      "activo"                 : activo
    };

    @override
    String toString() {
      return toJson().toString();
    }
}