
import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/pedido.dart';
import 'package:mercadito_a_distancia/models/producto.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';
import 'package:mercadito_a_distancia/pages/pedidos/cart_item_form.dart';
import 'package:mercadito_a_distancia/pages/pedidos/cart_list_item.dart';
import 'package:mercadito_a_distancia/pages/productos/product_list_item.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mercadito_a_distancia/providers/cart_provider.dart';
import 'package:mercadito_a_distancia/providers/productos_provider.dart';
import 'package:mercadito_a_distancia/providers/puntos_venta_provider.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:provider/provider.dart';
import 'package:mercadito_a_distancia/utils/utils.dart' as utils;
import 'package:intl/intl.dart';

import '../../widgets/modal_progress_overlay_widget.dart';
import '../../widgets/form_widgets/select_dropdown_option_widget.dart';
import '../../widgets/form_widgets/date_select_filter_widget.dart';

class PedidoAdminPage extends StatefulWidget {
  //Screen key
  static const String id = 'pedido_admin_page';

  @override
  _PedidoAdminPageState createState() => _PedidoAdminPageState();
}

class _PedidoAdminPageState extends State<PedidoAdminPage> {
  final TextEditingController _textBusquedaController = TextEditingController();
  //late StreamSubscription streamSubscriptionProductos;
  //late StreamSubscription streamSubscriptionPuntos;
  //final TextEditingController _filtroFechaController = TextEditingController();
  final DateFormat formatter = DateFormat("d 'de' MMMM, yyyy", 'es_MX');

  //For form validation
  final _pedidoFormKey = GlobalKey<FormState>();

  //Show Overlay while saving data
  late ProgressOverlayHandler _loadingHandler;
  ModalRoundedProgressOverlay? progressBar;

  //Prevent multiple taps over save button
  bool _guardando = false;

  //creation/update operations flag
  bool _esEdicion = false;

  //Object to save
  Pedido pedidoLocal = new Pedido();

  //Auxiliar store for products
  List<Producto>? productos = [];

  @override
  void initState() { 
    super.initState();
    //print('init state de Form Pedido');

    //Solo para create, para edit, sobreescribirá este valor con el pedido seleccionado
    pedidoLocal.puntoVenta = Provider.of<CartProvider>(context, listen: false).carritoCompras.puntoVenta;
    pedidoLocal.fechaPedido = Provider.of<CartProvider>(context, listen: false).carritoCompras.fechaPedido;
    //Aquí porque didChangeDependencies se llama cada vez que agregamos o eliminamos productos del carrito (cuando se crea, no cuando se edita)
    //_filtroFechaController.text = formatter.format((pedidoLocal.fechaPedido != null)? pedidoLocal.fechaPedido : DateTime.now());

    //Configure overlay
    progressBar = ModalRoundedProgressOverlay(
      handleCallback: (ProgressOverlayHandler handler) { _loadingHandler = handler;},
      message: 'Guardando...',
    );

    final repositorio = Provider.of<DataRepository>(context, listen: false);

    ///Escucha de los Stream's que leen datos de Firestore
    ///Se activa al recibir un documento agregado/actualizado/eliminado en RealTime
    ///Se checa cada uno de los cambios y se agregan o reemplazan en la base local sqlite
    final productosProvider = Provider.of<ProductosProvider>(context, listen: false);
    // streamSubscriptionProductos = repositorio.productosStream().listen( (querySnapShot) async {
    //   await repositorio.syncAndUpdateNewCloudProductosToLocalDB(querySnapShot, () {
    //     productosProvider.updateProducts();
    //   });
    // });

    final puntosProvider = Provider.of<PuntosVentaProvider>(context, listen: false);
    // streamSubscriptionPuntos = repositorio.puntosVentaStream().listen( (querySnapShot) async {
    //   await repositorio.syncAndUpdateNewCloudPuntosVentaToLocalDB(querySnapShot, () {
    //     puntosProvider.updatePuntosVenta();
    //   });
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //print('en didChangeDependencies del Pedido');
    Pedido? pedidoFromList = ModalRoute.of(context)!.settings.arguments as Pedido?;
    if (pedidoFromList != null) {
      pedidoLocal = pedidoFromList;
      //print(pedidoLocal);
      _esEdicion = true;
      //_filtroFechaController.text = formatter.format(pedidoLocal.fechaPedido);
    }
  }

  void dispose() {
    _textBusquedaController.dispose();
    //_filtroFechaController?.dispose();
    //Necesario cancelar la suscripción para no generar más listeners innecesarios
    //streamSubscriptionProductos.cancel();
    //streamSubscriptionPuntos.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('Construyendo pedido Form');

    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Form(
                key: _pedidoFormKey,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 0.0, left: 30.0, right: 30.0, bottom: 30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                child: Icon(Icons.shopping_cart_outlined, size: 30.0, color: Theme.of(context).primaryColor),
                                backgroundColor: Colors.white,
                                radius: 30.0,
                              ),
                              SizedBox(height: 10.0),
                              Text((_esEdicion)? 'Pedido ${describeEnum(pedidoLocal.estatus)}' : 'Pedido',
                                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: (_esEdicion)? 40.0 : 50.0, fontWeight: FontWeight.w700),
                              ),
                              Text((_esEdicion)? '${pedidoLocal.productosPedido!.length} Productos' :
                                '${Provider.of<CartProvider>(context).carritoCompras.productosPedido!.length} Producto(s)',
                                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18.0,),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
                          ),
                          child: Column(
                            children: [
                              _crearNombreCliente(),
                              buscarPuntosVenta(),
                              _crearFechaPedido(),
                              _crearValidadorProductos(),
                              productListSearch(),
                              _crearListadoProductos(),
                              SizedBox(height: 10.0,),
                              Divider(),
                              Text((_esEdicion)? 'Total: \$ ${pedidoLocal.total}' : 'Total: \$ ${Provider.of<CartProvider>(context).precioTotal}', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10.0),
                              //_crearBoton(context),
                              _crearBotonesGuardar(),
                              SizedBox(height: 15.0),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
            progressBar!
          ],
        ),
      ),
    );
  }

  Widget _crearNombreCliente() {
    return TextFormField(
      initialValue: pedidoLocal.nombreCliente,
      enabled: (pedidoLocal.estatus == EstatusPedido.recibido),
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Nombre del cliente',
        //icon: Icon(Icons.label_important, color: Colors.redAccent),
        contentPadding: EdgeInsets.all(0.0),
        isDense: true,
      ),
      //autofocus: true,
      maxLength: 50,
      validator: (valor) {
        if (valor!.length < 3) {
          return 'Ingrese el nombre del cliente';
        }
        return null;
      },
      onSaved: (valor) => pedidoLocal.nombreCliente = valor,
    );
  }

  Widget buscarPuntosVenta() {
    final repositorio = Provider.of<DataRepository>(context, listen: false);

    return Consumer<PuntosVentaProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<PuntoVenta>>(
          future: repositorio.getPuntosVentaDBLocalList(),
          builder: (context, puntosSnapshot) {
            if (!puntosSnapshot.hasData || puntosSnapshot.hasError) {
              return Center(
                child: (puntosSnapshot.hasError)? Text(sesionNoIniciada) : CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent),
              );
            }

            List puntosData = [];
            String? disabledPunto = '';
            for (var punto in puntosSnapshot.data!) {
              //Para mostrar el valor en caso de que ya este canceado o entregado
              if (pedidoLocal.puntoVenta != null && punto.id == pedidoLocal.puntoVenta) {
                disabledPunto = punto.nombre;
              }

              //Solo mostrar los puntos de venta activos si es registro
              if(!_esEdicion && punto.activo!) {
                puntosData.add({'id': punto.id, 'nombre': punto.nombre});
              } else if (_esEdicion && ( punto.activo! || (pedidoLocal.puntoVenta != null && punto.id == pedidoLocal.puntoVenta) )) {
                //En edición, si se pueden ver los puntos, pero solo se puede cambiar a uno de los activados
                puntosData.add({'id': punto.id, 'nombre': punto.nombre});
              }
            }

            return Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Icon(Icons.label_important, color: Colors.blueAccent),
                //SizedBox(width: 16),
                Expanded(
                  child: SelectDropDownOption(
                    value: pedidoLocal.puntoVenta,
                    options: puntosData,
                    disabledOption: disabledPunto,
                    optionKeyId: 'id',
                    optionValueId: 'nombre',
                    isEnabled: (pedidoLocal.estatus == EstatusPedido.recibido),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        //get and assing the value selected
                        pedidoLocal.puntoVenta = newValue;
                      }
                    },
                    hintText: 'Selecciona el punto de venta',
                    errorText: 'Selecciona el punto de venta',
                  ),
                  // child: DropdownButtonFormField<dynamic>(
                  //   value: pedidoLocal.puntoVenta,
                  //   hint: Text('Selecciona el punto de venta'),
                  //   disabledHint: Text(disabledPunto),
                  //   items: puntosData.map((punto) {
                  //     return DropdownMenuItem(
                  //       value: punto['id'],
                  //       child: Text(punto['nombre']),
                  //     );
                  //   }).toList(),
                  //   onChanged: (pedidoLocal.estatus == EstatusPedido.recibido)? (valor) => setState((){
                  //     pedidoLocal.puntoVenta = valor;
                  //   }) : null,
                  //   validator: (value) => value == null ? 'Selecciona el punto de venta' : null,
                  // ),
                ),
              ],
            );
          },
        );
      }
    );
  }

  Widget _crearFechaPedido() {
    DateTime fechaActual = DateTime.now();

    return DateSelectFilter(
      dateValue: (pedidoLocal.fechaPedido != null)? pedidoLocal.fechaPedido : fechaActual,
      initialDate: (pedidoLocal.fechaPedido != null)? pedidoLocal.fechaPedido : fechaActual,
      firstDate: (_esEdicion)? pedidoLocal.fecha : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      labelText: 'Fecha del pedido',
      errorText: 'Ingrese la fecha del pedido',
      isEnabled: (pedidoLocal.estatus == EstatusPedido.recibido),
      isMandatory: true,
      // onTap: (pickedDate) {
      //   if (pickedDate != null) {
      //     _filtroFechaController.text = formatter.format(pickedDate);
      //   }
      // },
      onSaved: (pickedDate) {
        if (pickedDate != null) {
          pedidoLocal.fechaPedido = pickedDate;
        }
      },
    );
    // return TextFormField(
    //   controller: _filtroFechaController,
    //   decoration: InputDecoration(
    //     labelText: 'Fecha del pedido',
    //     labelStyle: TextStyle(color: Colors.grey[700]),
    //     focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5)),
    //     border: UnderlineInputBorder(borderSide: BorderSide(width: 0.7)),
    //   ),
    //   readOnly: true,
    //   onTap: () async {
    //     DateTime fechaActual = DateTime.now();
    //     final DateTime pickedDate = await showDatePicker(
    //       context: context,
    //       initialDate: (pedidoLocal.fechaPedido != null)? pedidoLocal.fechaPedido : fechaActual,
    //       firstDate: (_esEdicion)? pedidoLocal.fecha : DateTime.now(),
    //       lastDate: DateTime.now().add(const Duration(days: 7)),
    //       //locale: Locale('es', 'MX'),
    //     );
    //     if (pickedDate != null) {
    //       // setState(() {
    //       //   _filtroFechaController.text = formatter.format(pickedDate);
    //       // });
    //     }
    //   },
    //   validator: (valor) {
    //     if (valor.isEmpty) {
    //       return 'Ingrese la fecha del pedido';
    //     }
    //     return null;
    //   },
    //   onSaved: (valor) {
    //     //pedidoLocal.fechaPedido = DateFormat("d 'de' MMMM, yyyy", 'es_MX').parse(valor);
    //   }
    // );
  }

  Widget _crearValidadorProductos() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Productos',
        labelStyle: TextStyle(color: Colors.black54),
        //icon: Icon(Icons.label_important, color: Colors.redAccent),
        contentPadding: EdgeInsets.all(0.0),
        isDense: true,
        //border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorStyle: TextStyle(
          color: Theme.of(context).errorColor, // Por el disabled no pone el color del error por default
        ),
      ),
      readOnly: true,
      enabled: false,
      validator: (value) {
        List? fuenteDatos = [];
        String msgError = 'Selecciona al menos un producto';
        if (_esEdicion) {
          fuenteDatos = pedidoLocal.productosPedido!.where((p) => p.disponible!).toList();
          msgError = 'Se requiere al menos un producto disponible';
        } else {
          fuenteDatos = Provider.of<CartProvider>(context, listen: false).carritoCompras.productosPedido;
        }
        return fuenteDatos!.isEmpty ? msgError : null;
      }
    );
  }

  Widget productListSearch() {
    final repositorio = Provider.of<DataRepository>(context, listen: false);

    return Consumer<ProductosProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<Producto>>(
          future: repositorio.getProductosDBLocalList(),
          builder: (context, productosSnapshot) {
            if (!productosSnapshot.hasData || productosSnapshot.hasError) {
              //print(productosSnapshot.error);
              return Center(
                child: (productosSnapshot.hasError)? Text(sesionNoIniciada) : CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent),
              );
            }

            switch (productosSnapshot.connectionState) {
              case ConnectionState.waiting: return CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent);
              default:
            }

            // final productsData = snapshot.data.docs;
            productos = productosSnapshot.data;
            // for(var productData in productsData) {
            //   final Producto producto = Producto.fromJson(productData.data(), productData.id);
            //   producto.id = productData.id;
            //   productos.add(producto);
            // }

            return Material(
              color: Colors.transparent,
              //elevation: 35.0,
              child: TypeAheadField(
                direction: AxisDirection.up, //Para que las sugerencias se muestren hacia arriba
                textFieldConfiguration: TextFieldConfiguration(
                  enabled: (pedidoLocal.estatus == EstatusPedido.recibido),
                  autofocus: false,
                  enableSuggestions: true,
                  keyboardType: TextInputType.name,
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  decoration: InputDecoration(
                    //border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(50.0)),
                    prefixIcon: Icon(Icons.search),
                    // contentPadding: EdgeInsets.all(20.0),
                    //enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.5), borderRadius: BorderRadius.circular(50.0)),
                  ),
                  controller: _textBusquedaController,
                ),
                noItemsFoundBuilder: (BuildContext context) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No hay conicidencias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).disabledColor, fontSize: 18.0),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return productosSnapshot.data!.where((i) => i.disponible! && utils.valuewithoutDiacritics(i.nombre)!.toLowerCase().contains(utils.valuewithoutDiacritics(pattern)!.toLowerCase())).toList();
                },
                itemBuilder: (context, Producto producto) {
                  return ProductItem(
                    item: producto,
                    itemForList: false,
                  );
                },
                onSuggestionSelected: (Producto producto) async {
                  //print('Dentro de onSuggestionSelected');
                  var cartItem = await _crearFormCartItem(context, producto);
                  if (cartItem != null) {
                    //print('No es nula la selección');
                    _textBusquedaController.clear();
                    if (_esEdicion) {
                      //print('Es actualización de pedido');
                      setState(() {
                        pedidoLocal.productosPedido!.add(cartItem);
                        pedidoLocal.total = pedidoLocal.productosPedido!.where((pr) => pr.disponible!).map<double>((p) => p.precio!).fold(0, (a,b) => a! + b);
                        //pedidoLocal.total = pedidoLocal.productosPedido.map<double>((p) => p.precio).fold(0, (a,b)=>a + b);
                        //pedidoLocal.total = pedidoLocal.productosPedido.map<double>((p) => p.precio).reduce((a,b)=>a + b);
                      });
                    } else {
                      //print('En nuevo pedido');
                      Provider.of<CartProvider>(context, listen: false).add(cartItem);
                    }
                  }
                },
              ),
            );

          },
        );
      }
    );
  }

  Widget _crearListadoProductos() {
    if (_esEdicion) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        //padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        itemCount: pedidoLocal.productosPedido!.length,
        itemBuilder: (BuildContext context, int index) {
          var prodItem = productos!.firstWhereOrNull((p) => p.id == pedidoLocal.productosPedido![index].idProducto);
          String unidad = (prodItem != null)? (prodItem.precioPorUnidad != null)? '' : 'kilos' : 'kilos';
          return ListCartItem(
            item: pedidoLocal.productosPedido![index],
            esEdicion: true,
            esEditable: (pedidoLocal.estatus == EstatusPedido.recibido),
            unidadMedida: unidad,
            onDeleteUpdate: (bool? value) {
              //print('Desmarcando producto');
              setState(() {
                pedidoLocal.productosPedido![index].disponible = value;
                //pedidoLocal.productosPedido.removeAt(index);
                pedidoLocal.total = pedidoLocal.productosPedido!.where((pr) => pr.disponible!).map<double>((p) => p.precio!).fold(0, (a,b) => a! + b);
              });
            }
          );
        },
      );
    } else {
      return Consumer<CartProvider>(
        builder: (context, carrito, child) {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            //padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            itemCount: carrito.totalProductos,
            itemBuilder: (BuildContext context, int index) {
              var prodItem = productos!.firstWhereOrNull((p) => p.id == carrito.carritoCompras.productosPedido![index].idProducto);
              String unidad = (prodItem != null)? (prodItem.precioPorUnidad != null)? '' : 'kilos' : 'kilos';
              return ListCartItem(
                item: carrito.carritoCompras.productosPedido![index],
                unidadMedida: unidad,
                onDeleteCreate: () {
                  //print('Eliminando producto');
                  carrito.delete(index);
                }
              );
            },
          );
        },
      );
    }
  }

  _crearFormCartItem(BuildContext context, Producto producto) async {
    var alert = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
      child: FormCartItem(producto: producto),
      //elevation: 0.0,
      //backgroundColor: Colors.transparent,
    );

    // show the dialog
    var cartItem = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return cartItem;
  }

  Widget _crearBotonesGuardar() {

    ElevatedButton btnActualizar = ElevatedButton.icon(
      label: Text((_esEdicion)? 'Actualizar' : 'Registrar pedido'),
      icon: Icon(Icons.add_shopping_cart),
      onPressed: (_guardando)? null : () {
        _submit(context, pedidoLocal.estatus);
      }
    );

    ElevatedButton btnPreparar = ElevatedButton.icon(
      label: Text('Preparar'),
      icon: Icon(Icons.fact_check_outlined),
      
      onPressed: (_guardando)? null : () {
        _submit(context, EstatusPedido.preparado);
      }
    );

    ElevatedButton btnEntregar = ElevatedButton.icon(
      label: Text('Entregar'),
      icon: Icon(Icons.delivery_dining),
      
      onPressed: (_guardando)? null : () async {
        //Mostrar Alert para confirmar la operación
        bool? confirmacion = await utils.mostrarConfirmar(context, 'Confirma la entrega del pedido', 'No será posible editar el pedido una vez entregado', 'Cerrar', 'Si, entregar');
        if (confirmacion != null && confirmacion) {
          _submit(context, EstatusPedido.entregado);
        }
      }
    );

     ElevatedButton btnCancelar = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        onPrimary: Theme.of(context).errorColor,
        primary: Theme.of(context).scaffoldBackgroundColor,
      ),
      label: Text('Cancelar'),
      icon: Icon(Icons.cancel_outlined),
      onPressed: (_guardando)? null : () async {
        //Mostrar Alert para confirmar la operación
        bool? confirmacion = await utils.mostrarConfirmar(context, '¿Cancelar el pedido?', 'No será posible editar el pedido una vez cancelado', 'Cerrar', 'Si, cancelar');
          if (confirmacion != null && confirmacion) {
          _submit(context, EstatusPedido.cancelado);
        }
      }
    );

    ElevatedButton btnDeshacer = ElevatedButton.icon(
      label: Text('Deshacer'),
      icon: Icon(Icons.arrow_back_outlined),
      onPressed: (_guardando)? null : () {
        _submit(context, EstatusPedido.recibido);
      }
    );

    if (Provider.of<UsuarioProvider>(context).usuario!.rol == rolAdmin) {
      if (!_esEdicion) {
        return Center(
          child: btnActualizar,
        );
      } else {
        List<Widget> botones = [];
        switch (pedidoLocal.estatus) {
          case EstatusPedido.recibido:
            botones.addAll([
              Expanded(flex: 5, child: btnActualizar),
              Expanded(flex: 1, child: Container()),
              Expanded(flex: 5, child: btnPreparar),
            ]);
            break;
          case EstatusPedido.preparado:
            botones.addAll([
              Expanded(flex: 5, child: btnDeshacer),
              Expanded(flex: 1, child: Container()),
              Expanded(flex: 5, child: btnEntregar),
            ]);
            break;
          case EstatusPedido.entregado:
          case EstatusPedido.cancelado:
            return Container();
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: botones,
            ),
            SizedBox(height: 20),
            Center(child: btnCancelar)
          ],
        );
      }
    } else {
      return Container();
    }
  }

  void _submit(BuildContext context, EstatusPedido nuevoEstatus) async {
    //print("Guardando");
    //Si el form no pasa las validaciones
    if (!_pedidoFormKey.currentState!.validate() ) return;

    //Avoid double save button tap and Show overlay before save
    _guardando = true;
    _loadingHandler.show();

    //Dispara los onSaved de todos los inputs del formulario
    _pedidoFormKey.currentState!.save();

    //print('Todo chido!');
    //print(pedidoLocal);

    try {
      if (_esEdicion) {
        await editarItem(nuevoEstatus);
      } else {
        await agregarItem();
      }

      //await Future.delayed(Duration(seconds: 3));
    } on Exception catch (e) {
      print(e.toString());
      utils.mostrarAlertaFuture(context, "Ha ocurrido un error, por favor, intente más tarde");
    } finally {
      //Enable save button and Hide overlay after save or error
      _guardando = false;
      _loadingHandler.dismiss();
    }
  }

  Future<void> agregarItem() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    //Nuevo objeto para que tome la fecha al momento y el estatus inicial del constructor default
    pedidoLocal.productosPedido = cartProvider.carritoCompras.productosPedido;
    pedidoLocal.total = cartProvider.precioTotal;
    pedidoLocal.fecha = DateTime.now();
    //Se registra/actualiza la fecha de ultima actualización del producto
    pedidoLocal.ultimaActualizacion = DateTime.now();
    //Se registra el id que usará el nuevo regitro
    final repositorio = Provider.of<DataRepository>(context, listen: false);
    Pedido? ultimoInsertado = await repositorio.getLastInsertedPedidoDBLocal();
    pedidoLocal.id = (ultimoInsertado != null)? ((int.tryParse(ultimoInsertado.id!) ?? 0) + 1).toString() : '1';

    cartProvider.carritoCompras.puntoVenta = pedidoLocal.puntoVenta;
    cartProvider.carritoCompras.fechaPedido = pedidoLocal.fechaPedido;

    bool respuesta = await repositorio.upsertPedidos([pedidoLocal]);
    if (respuesta) {
      cartProvider.vaciarCarrito();
      Navigator.pushReplacementNamed(context, 'pedido_admin_page');
    } else {
      utils.mostrarAlertaFuture(context, "Ha ocurrido un error, por favor, intente más tarde");
    }
  }

  Future<void> editarItem(EstatusPedido nuevoEstatus) async {
    pedidoLocal.estatus = nuevoEstatus;
    //Se registra/actualiza la fecha de ultima actualización del producto
    pedidoLocal.ultimaActualizacion = DateTime.now();
    final database = Provider.of<DataRepository>(context, listen: false);
    bool respuesta = await database.upsertPedidos([pedidoLocal]);
    if (respuesta) {
      Navigator.pop(context);
    } else {
      utils.mostrarAlertaFuture(context, "Ha ocurrido un error, por favor, intente más tarde");
    }
  }
}