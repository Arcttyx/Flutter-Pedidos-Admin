import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromRGBO(223, 50, 131, 1);

const kSendButtonTextStyle = TextStyle(
  color: kPrimaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kPrimaryColor, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your email',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const categoriasProductos = <String>['Carnes', 'Semillas', 'Frutas y Verduras', 'Abarrotes', 'Carnes, Pescados y Mariscos', 'Lácteos', 'Jugos y Bebidas', 'Panadería', 'Confitería', 'Otros'];
const unidadKilo = 'kilo';
const unidadMedioKilo = 'medio';
const unidadCuartoKilo = 'cuarto';
const unidadEntera = 'unidad';
const sesionNoIniciada = 'Inicia sesión para realizar ésta operación';
const camposVaciosRegistro = 'Ingresa todos los campos del registro para crear tu cuenta';
const idAuthKey = 'id_auth';
const idDocKey = 'id_doc';

const kUsersCollection = 'users';
const kPedidosCollection = 'pedidos';
const kProductosCollection = 'products';
const kPuntosCollection = 'puntos';

const estatusRecibido = 'recibido';
const estatusPreparado = 'preparado';
const estatusEntregado = 'entregado';
const estatusCancelado = 'cancelado';
enum EstatusPedido {recibido, preparado, entregado, cancelado}

const rolAdmin = 'Administrador';
const rolProveedor = 'Proveedor';
const rolConsulta = 'Consulta';
const rolesUsuarios = <String>[rolAdmin, rolConsulta];

const tablaProductos = 'products';
const tablaPedidos = 'pedidos';
const tablaPuntos = 'puntos';