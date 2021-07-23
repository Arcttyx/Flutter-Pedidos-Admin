import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/pedido.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';
import 'package:mercadito_a_distancia/pages/pedidos/pedido_list_item.dart';
import 'package:mercadito_a_distancia/pages/pedidos/pedidos_filters_widget.dart';
import 'package:mercadito_a_distancia/providers/pedidos_filters_provider.dart';
import 'package:mercadito_a_distancia/providers/pedidos_provider.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:provider/provider.dart';
import 'package:mercadito_a_distancia/utils/utils.dart' as utils;

class PedidosListPage extends StatefulWidget {
  static const String id = 'pedidos_list_page';

  @override
  _PedidosListPageState createState() => _PedidosListPageState();
}

class _PedidosListPageState extends State<PedidosListPage> {
  TextEditingController _buscadorTextController = TextEditingController();
  //late StreamSubscription streamSubscription;
  Map<String?, PuntoVenta> puntosData = {};

  @override
  void initState() { 
    super.initState();
  
    final repositorio = Provider.of<DataRepository>(context, listen: false);
    final pedidosProvider = Provider.of<PedidosProvider>(context, listen: false);

    ///Escucha del Stream que lee datos de Firestore
    ///Se activa al recibir un documento agregado/actualizado/eliminado en RealTime
    ///Se checa cada uno de los cambios y se agregan o reemplazan en la base local sqlite
    // streamSubscription = repositorio.pedidosStream().listen( (querySnapShot) async {
    //   await repositorio.syncAndUpdateNewCloudPedidosToLocalDB(querySnapShot, () {
    //     pedidosProvider.updatePedidos();
    //   });
    // });

    getPuntos();
  }

  void dispose() {
    _buscadorTextController.dispose();
    //Necesario cancelar la suscripción para no generar más listeners innecesarios
    //streamSubscription.cancel();
    super.dispose();
  }

  //Funcion para obtener la lista de puntos de la BD local (Necesario de BD local, porque si fuera de Firestore serían (X cantidad como Puntos existan) consultas constantes cada que entramos a esta pantalla)
  //y armar una List indexada por id para mostrar el nombre del punto en vez del id
  //a la hora de crear el Pedido Item en la lista de Pedidos
  //Se puede sacar haciendo un Join entre Pedidos y Puntos también, pero se 
  //deja este código para futuras referencias
  void getPuntos() async {
    final repositorio = Provider.of<DataRepository>(context, listen: false);
    List<PuntoVenta> puntos = await repositorio.getPuntosVentaDBLocalList();
    for (PuntoVenta punto in puntos) {
      puntosData[punto.id] = punto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Lista de pedidos'),
        leading: Builder(
          builder: (BuildContext context) {
            //Se pone explicitamente el botón de atrás, porque el enddrawer lo oculta
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () { Navigator.pop(context); },
            );
          },
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
          ),
        ],
      ),
      endDrawer: PedidosFiltersWidget(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _buscadorTextController,
                decoration: InputDecoration(
                  hintText: 'Busca por nombre de cliente',
                ),
                onChanged: (value) {
                  setState(() { });
                },
              ),
            ),
            pedidosList()
          ],
        ),
      ),
    );
  }

  Widget pedidosList() {
    bool esAdmin = (Provider.of<UsuarioProvider>(context, listen: false).usuario!.rol == rolAdmin)? true : false;
    final repositorio = Provider.of<DataRepository>(context, listen: false);

    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<Pedido>>(
          future: repositorio.getPedidosDBLocalList(),
          builder: (BuildContext context, AsyncSnapshot<List<Pedido>> pedidosSnapshot) {
            if (!pedidosSnapshot.hasData || pedidosSnapshot.hasError) {
              return Center(
                child: (pedidosSnapshot.hasError)? Text(sesionNoIniciada) : CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent),
              );
            }

            return Consumer<PedidosFiltersProvider>(
              builder: (context, filterData, child) {

                final List<Pedido> pedidosData = pedidosSnapshot.data!;
                List<Pedido> pedidos = [];
                bool esBuscado;
                for(var pedido in pedidosData) {
                  //final Pedido pedido = Pedido.fromJson(productData.data(), productData.id);
                  //final Pedido pedido = Pedido();
                  //pedido.id = productData.id;

                  esBuscado = true;
                  //Si cumple la condición de búsqueda, se agrega a la lista de pedidos
                  if (!(_buscadorTextController.text.isEmpty || utils.valuewithoutDiacritics(pedido.nombreCliente)!.toLowerCase().contains(utils.valuewithoutDiacritics(_buscadorTextController.text)!.toLowerCase()))) {
                    esBuscado = false;
                  }

                  //Si no hay filtro, por default oculta los cancelados y ya entregados para el admin
                  if (esAdmin && (filterData.estatus == null) && (pedido.estatus == EstatusPedido.cancelado || pedido.estatus == EstatusPedido.entregado)) {
                    esBuscado = false;
                  }

                  if (filterData.punto != null && pedido.puntoVenta != filterData.punto) {
                    esBuscado = false;
                  }
                  if (filterData.fecha != null && !isSameDate(pedido.fechaPedido, filterData.fecha)) {
                    esBuscado = false;
                  }
                  if (filterData.estatus != null && pedido.estatus != filterData.estatus) {
                    esBuscado = false;
                  }

                  if (esBuscado) {
                    pedidos.add(pedido);
                  }
                }

                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    itemCount: pedidos.length,
                    itemBuilder: (BuildContext context, int index) {
                      //final Pedido pedido = Pedido.fromJson(pedidosData.elementAt(index).data());
                      //pedido.id = pedidosData.elementAt(index).id;
                      return PedidoItem(
                        item: pedidos[index],
                        puntosData: puntosData,
                        onTap: () {
                          Navigator.pushNamed(context, 'pedido_admin_page', arguments: pedidos[index]);
                        },
                      );
                    },
                  ),
                );
              }
            );

          },
        );
      }
    );
  }

  bool isSameDate(DateTime? date1, date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}