import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/pedido.dart';
import 'package:mercadito_a_distancia/providers/pedidos_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:collection/collection.dart';

class SolicitadoListPage extends StatefulWidget {
  static const String id = 'solicitado_list_page';

  @override
  _SolicitadoListPageState createState() => _SolicitadoListPageState();
}

class _SolicitadoListPageState extends State<SolicitadoListPage> {
  TextEditingController _filtroFechaController = TextEditingController();
  //late StreamSubscription streamSubscription;
  DateTime? _filtroFecha;

  auth.User? loggedInUser;
  final DateFormat formatter = DateFormat("(y/MM/dd)dd 'de' MMMM, yyyy", 'es_MX');

  @override
  void initState() { 
    super.initState();
    
    final repositorio = Provider.of<DataRepository>(context, listen: false);
    final productosProvider = Provider.of<PedidosProvider>(context, listen: false);

    ///Escucha del Stream que lee datos de Firestore
    ///Se activa al recibir un documento agregado/actualizado/eliminado en RealTime
    ///Se checa cada uno de los cambios y se agregan o reemplazan en la base local sqlite
    // streamSubscription = repositorio.pedidosStream().listen( (querySnapShot) async {
    //   await repositorio.syncAndUpdateNewCloudPedidosToLocalDB(querySnapShot, () {
    //     productosProvider.updatePedidos();
    //   });
    // });
  }

  void dispose() {
    _filtroFechaController.dispose();
    //Necesario cancelar la suscripción para no generar más listeners innecesarios
    //streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Productos solicitados por día'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _crearFiltroFecha(),
            solicitadosListPorDia()
          ],
        ),
      ),
    );
  }

  Widget _crearFiltroFecha() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _filtroFechaController,
        decoration: InputDecoration(
          labelText: 'Fecha de los pedidos',
          labelStyle: TextStyle(color: Colors.grey[700]),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5)),
          border: UnderlineInputBorder(borderSide: BorderSide(width: 0.7)),
          
        ),
        readOnly: true,
        onTap: () async {
          DateTime fechaActual = DateTime.now();
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: (_filtroFecha != null)? _filtroFecha! : fechaActual,
            firstDate: DateTime(2020, 2, 9),
            lastDate: DateTime.now(),
            //locale: Locale('es', 'MX'),
          );
          if (pickedDate != null && pickedDate != fechaActual) {
            setState(() {
              _filtroFechaController.text = formatter.format(pickedDate).substring(12);
              _filtroFecha = pickedDate;
            });
          }
        },
      ),
    );
  }

  Widget solicitadosListPorDia() {
    final repositorio = Provider.of<DataRepository>(context, listen: false);

    return Consumer<PedidosProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<Pedido>>(
          future: repositorio.getPedidosDBLocalList(),
          builder: (BuildContext context, AsyncSnapshot<List<Pedido>> pedidosSnapshot) {
            if (!pedidosSnapshot.hasData || pedidosSnapshot.hasError) {
              print(pedidosSnapshot.error);
              return Center(
                child: (pedidosSnapshot.hasError)? Text(sesionNoIniciada) : CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent),
              );
            }

            final List<Pedido> pedidosData = pedidosSnapshot.data!;
            List<Pedido> pedidos = [];
            bool esBuscado;

            //Aplicar filtros de búsqueda
            for(Pedido pedido in pedidosData) {
              //final Map<String, dynamic> pedido = pedidoData.data();

              esBuscado = true;
              if (_filtroFechaController.text.isNotEmpty) {
                //Si hay filtro debe coincidir con la fecha buscada
                if (!isSameDate(pedido.fechaPedido!, _filtroFecha!)) {
                  esBuscado = false;
                }
              } else {
                //Si no hay filtro, por default busca los productos pedidos del día
                // if (!isSameDate(DateTime.now(), pedido['fecha_pedido'].toDate())) {
                //   esBuscado = false;
                // }
              }

              if (esBuscado) {
                pedidos.add(pedido);
              }
            }

            // print('Filtrados');

            //AGRUPAR PEDIDOS POR FECHA
            //{9 de febrero, 2021: [{fecha: .....}, {fecha: ...}], 8 de febrero, 2021: [{fecha: .....}, {fecha: ...}]}
            var pedidosPorDia = groupBy(pedidos, (Pedido obj) => formatter.format(obj.fechaPedido!));
            // print(pedidosPorDia);

            //Crear una lista con la suma de las cantidades de todos los productos de los pedidos por día
            //[{fecha: 9 de febrero, 2021, productos: {Maciza De Puerco : 10.5, Pastor De Puerco : 14.5 ...}, {fecha: 8 de febrero, 2021, productos: {Jugos Arándano Artesanal: 15.0, Papel Pétalo : 30.0 ...} }]
            List<dynamic> listaProductosAgrupados = [];
            pedidosPorDia.forEach((fechaGroup, pedidosGroup) {
              Map<String, double> cantidadesProductos = {};
              double totalVentaPorFecha = 0.0;
              double totalRecibidosPorFecha = 0.0;
              double totalPreparadosPorFecha = 0.0;
              double totalEntregadosPorFecha = 0.0;
              double totalCanceladosPorFecha = 0.0;
              pedidosGroup.forEach((pedidoData) {
                //Iterar sobre los pedidos de esa fecha
                pedidoData.productosPedido!.forEach((productoDelPedido) {
                  String nombreProducto = productoDelPedido.nombreProducto?? '';
                  //Solo tomamos en cuenta los productos que sí se solicitaron y se omiten los productos cancelados/tachados de los pedidos
                  if (productoDelPedido.disponible!) {
                    if (cantidadesProductos.containsKey(nombreProducto)) {
                      //cantidadesProductos[nombreProducto] += double.parse(productoDelPedido.cantidad.toString());
                      cantidadesProductos[nombreProducto] = (cantidadesProductos[nombreProducto]?? 0) + double.parse(productoDelPedido.cantidad.toString());
                    } else {
                      cantidadesProductos[nombreProducto] = (productoDelPedido.cantidad != null)? double.parse(productoDelPedido.cantidad.toString()) : 0.0;
                    }
                  }
                });
                // Ir sumando el total del pedido al total del grupo de pedidos de esa fecha
                totalVentaPorFecha += pedidoData.total!;
                //Suma total por estatus de los pedidos de esa fecha
                switch (describeEnum(pedidoData.estatus)) {
                  case estatusRecibido:
                    totalRecibidosPorFecha += pedidoData.total!;
                    break;
                  case estatusPreparado:
                    totalPreparadosPorFecha += pedidoData.total!;
                    break;
                  case estatusEntregado:
                    totalEntregadosPorFecha += pedidoData.total!;
                    break;
                  case estatusCancelado:
                    totalCanceladosPorFecha += pedidoData.total!;
                    break;
                  default:
                }
              });

              listaProductosAgrupados.add({
                'fecha_pedido': fechaGroup,
                'cantidades_productos': cantidadesProductos,
                'total_venta_por_fecha': totalVentaPorFecha,
                'total_recibidos': totalRecibidosPorFecha,
                'total_preparados': totalPreparadosPorFecha,
                'total_entregados': totalEntregadosPorFecha,
                'total_cancelados': totalCanceladosPorFecha,
              });
            });
            // print('After iteración');
            // print(listaProductosAgrupados[2]);
            //return Container();
            return Expanded(
              child: GroupedListView<dynamic, String?>(
                elements: listaProductosAgrupados,
                groupBy: (element) => element['fecha_pedido'],
                //groupComparator: (value1, value2) => value2.compareTo(value1),
                //itemComparator: (item1, item2) => item1['id'].compareTo(item2['id']),
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                groupSeparatorBuilder: (String? value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Pedidos del ${value!.substring(12)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                itemBuilder: (c, element) {
                  //print(element);
                  String listaTotalSolicitado = '';
                  List<String> listaProductosPedidos = [];
                  element['cantidades_productos'].forEach((itemProductoNombre, itemProducoCantidad) {
                    listaProductosPedidos.add('$itemProductoNombre:  $itemProducoCantidad');
                    //listaTotalSolicitado += '$itemProductoNombre:  $itemProducoCantidad \n';
                  });
                  listaProductosPedidos.sort();
                  listaTotalSolicitado = listaProductosPedidos.join('\n');
                  //listaTotalSolicitado += "\nTotal vendido: ${element['total_venta_por_fecha'].toString()}";
                  return Card(
                    elevation: 8.0,
                    margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      //leading: Icon(Icons.account_circle),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(listaTotalSolicitado, textAlign: TextAlign.start),
                          Text("Total estimado: \$ ${element['total_venta_por_fecha'].toStringAsFixed(2)}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('Vendido: \$${element['total_entregados'].toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                              Text('No vendido: \$${(element['total_recibidos'] + element['total_preparados'] + element['total_cancelados']).toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      }
    );
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}