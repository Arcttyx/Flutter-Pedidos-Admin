import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mercadito_a_distancia/models/producto.dart';
import 'package:mercadito_a_distancia/pages/productos/product_list_item.dart';
import 'package:mercadito_a_distancia/utils/utils.dart' as utils;

import '../cart_item_form.dart';


//Clase experimental para tratar de deshacernos del setState del filtro de productos
class ProductSelectFilterForPedido extends StatefulWidget {
  const ProductSelectFilterForPedido({
    required this.productos,
    required this.onSuggestionSelected,
    this.isEnabled = true,
  });

  final List<Producto> productos;
  final Function onSuggestionSelected;
  final bool isEnabled;

  @override
  _ProductSelectFilterForPedidoState createState() => _ProductSelectFilterForPedidoState();
}

class _ProductSelectFilterForPedidoState extends State<ProductSelectFilterForPedido> {
  final TextEditingController _textBusquedaController = TextEditingController();

  void dispose() {
    _textBusquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      direction: AxisDirection.up, //Para que las sugerencias se muestren hacia arriba
      textFieldConfiguration: TextFieldConfiguration(
        enabled: widget.isEnabled,
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
        return widget.productos.where((i) => i.disponible! && utils.valuewithoutDiacritics(i.nombre)!.toLowerCase().contains(utils.valuewithoutDiacritics(pattern)!.toLowerCase())).toList();
      },
      itemBuilder: (context, dynamic producto) {
        return ProductItem(
          item: producto,
          itemForList: false,
        );
      },
      onSuggestionSelected: (Producto producto) async {
        var cartItem = await _crearFormCartItem(context, producto);
        if (cartItem != null) {
          _textBusquedaController.clear();
          widget.onSuggestionSelected(cartItem);
          // if (_esEdicion) {
          //   setState(() {
          //     pedidoLocal.productosPedido.add(cartItem);
          //     pedidoLocal.total = pedidoLocal.productosPedido.where((pr) => pr.disponible).map<double>((p) => p.precio).fold(0, (a,b)=>a + b);
          //     //pedidoLocal.total = pedidoLocal.productosPedido.map<double>((p) => p.precio).fold(0, (a,b)=>a + b);
          //     //pedidoLocal.total = pedidoLocal.productosPedido.map<double>((p) => p.precio).reduce((a,b)=>a + b);
          //   });
          // } else {
          //   Provider.of<CartProvider>(context, listen: false).add(cartItem);
          // }
        }
      },
    );
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
}