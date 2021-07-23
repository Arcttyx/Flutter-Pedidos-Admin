import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/cart_item.dart';

class Pedido {
    String? id;
    DateTime? fecha; //auto, fecha de registro
    DateTime? fechaPedido; //auto
    String? nombreCliente; //form
    String? puntoVenta; //form
    double? subtotal;
    double? otrosGastos;
    double? total;
    List<CartItem>? productosPedido; //form
    String? repartidor; //form
    EstatusPedido estatus; //auto al inicio
    DateTime? ultimaActualizacion; //auto, fecha de ultima actualización
    bool? eliminado;

    Pedido({
      this.id,
      this.nombreCliente,
      this.fecha,
      this.fechaPedido,
      this.puntoVenta,
      this.subtotal,
      this.otrosGastos,
      this.total,
      this.productosPedido,
      this.repartidor,
      this.estatus = EstatusPedido.recibido,
      this.ultimaActualizacion,
      this.eliminado = false
    }) {
      if (this.productosPedido == null) {
        this.productosPedido = [];
      }
    }

    //Usado para desconvertir de Firestore
    factory Pedido.fromJson(Map<String, dynamic> json, String id) {
      //lista de productos es una subestructura de Strings en firebase dentro del pedido
      List<CartItem> listaProductosPedido = [];
      if ( json["productos_pedido"] != null ) {
        json["productos_pedido"].forEach((v) => listaProductosPedido.add(CartItem.fromJson(v)));
      }

      return Pedido(
        id                : id,
        nombreCliente     : json["nombre_cliente"],
        fecha             : json["fecha"].toDate(),
        fechaPedido       : json["fecha_pedido"] == null? null : json["fecha_pedido"].toDate(),
        puntoVenta        : json["punto_venta"],
        subtotal          : json["subtotal"],
        otrosGastos       : json["otros_gastos"],
        total             : json["total"],
        repartidor        : json["repartidor"],
        productosPedido   : listaProductosPedido,
        estatus           : EstatusPedido.values.firstWhere((e) => e.toString() == 'EstatusPedido.' + json["estatus"]),
        ultimaActualizacion  : json["ultima_actualizacion"] == null? null : json["ultima_actualizacion"].toDate(),
        eliminado            : json["eliminado"] == null ? false : json["eliminado"],
      );
    }

    //Usado para desconvertir de SQLite
    factory Pedido.fromDBJson(Map<String, dynamic> dbEntry) {
      //lista de productos es una subestructura de Strings en firebase dentro del pedido
      List<CartItem> listaProductosPedido = [];
      if ( dbEntry["productos_pedido"] != null ) {
        jsonDecode(dbEntry["productos_pedido"]).forEach((v) => listaProductosPedido.add(CartItem.fromJson(v)));
      }

      //ISO 8601 String --> DateTime:     DateTime dateTime = DateTime.parse('2020-04-17T11:59:46.405');
      return Pedido(
        id                   : dbEntry["id"],
        nombreCliente        : dbEntry["nombre_cliente"],
        fecha                : dbEntry["fecha"] == null? null : DateTime.parse(dbEntry["fecha"]),
        fechaPedido          : dbEntry["fecha_pedido"] == null? null : DateTime.parse(dbEntry["fecha_pedido"]),
        puntoVenta           : dbEntry["punto_venta"],
        subtotal             : dbEntry["subtotal"],
        otrosGastos          : dbEntry["otros_gastos"],
        total                : dbEntry["total"],
        repartidor           : dbEntry["repartidor"],
        productosPedido      : listaProductosPedido,
        estatus              : dbEntry["estatus"] == null? EstatusPedido.recibido : EstatusPedido.values.firstWhere((e) => e.toString() == 'EstatusPedido.' + dbEntry["estatus"]),
        ultimaActualizacion  : dbEntry["ultima_actualizacion"] == null? null : DateTime.parse(dbEntry["ultima_actualizacion"]),
        eliminado            : (dbEntry["eliminado"] == null)? false : (dbEntry["eliminado"] == 1)? true : false,
      );
    }

    //Usado para guardar en FIrestore
    Map<String, dynamic> toJson() {
      List<String> productos = [];
      productosPedido!.forEach((item) {
        productos.add(item.toString());
      });

      return {
        "id"                     : id,
        "nombre_cliente"         : nombreCliente,
        "fecha"                  : fecha,
        "fecha_pedido"           : fechaPedido,
        "punto_venta"            : puntoVenta,
        "subtotal"               : subtotal,
        "otros_gastos"           : otrosGastos,
        "total"                  : total,
        "repartidor"             : repartidor,
        "productos_pedido"       : productosPedido!.map((i) => i.toJson()).toList(),
        "estatus"                : describeEnum(estatus),
        "ultima_actualizacion"   : ultimaActualizacion,
        "eliminado"              : eliminado
      };
    }

    //Usado para guardar en SQLite
    //Los campos deben coresponder a las columnas de la tabla en sqlite
    //DateTime --> ISO 8601 String:     String timeStamp = DateTime.now().toIso8601String();
    Map<String, dynamic> toDBJson() {
      return {
        "id"                     : id,
        "nombre_cliente"         : nombreCliente,
        "fecha"                  : (fecha == null)? null : fecha!.toIso8601String(),
        "fecha_pedido"           : (fechaPedido == null)? null : fechaPedido!.toIso8601String(),
        "punto_venta"            : puntoVenta,
        "total"                  : total,
        "productos_pedido"       : jsonEncode(productosPedido),
        "estatus"                : describeEnum(estatus),
        "ultima_actualizacion"   : (ultimaActualizacion == null)? null : ultimaActualizacion!.toIso8601String(),
        "eliminado"              : (eliminado == null)? 0 : (eliminado! == true)? 1 : 0,
      };
    }

    @override
    String toString() {
      return toJson().toString();
    }
}