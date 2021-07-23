class CartItem {
  String? id;
  String? idProducto;
  String? nombreProducto;
  String? detalles;
  double? cantidad;
  double? precio;
  bool? disponible;

  CartItem({this.id, this.idProducto, this.nombreProducto, this.detalles, this.cantidad, this.precio, this.disponible = true});

  Map<String, dynamic> toJson() => {
    "id"                     : id,
    "id_producto"            : idProducto,
    "nombre_producto"        : nombreProducto,
    "detalles"               : detalles,
    "cantidad"               : cantidad,
    "precio"                 : precio,
    "disponible"             : disponible
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    //print(json);
    return CartItem(
      id                : json["id"],
      idProducto        : json["id_producto"],
      nombreProducto    : json["nombre_producto"],
      detalles          : json["detalles"],
      cantidad          : double.parse(json["cantidad"].toString()),
      precio            : double.parse(json["precio"].toString()),
      disponible        : json["disponible"],
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}