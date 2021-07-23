import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/models/cart_item.dart';
import 'package:mercadito_a_distancia/models/producto.dart';

// Create a Form widget.
class FormCartItem extends StatefulWidget {

  final Producto? producto;

  FormCartItem({
    this.producto
  });

  @override
  FormCartItemState createState() {
    return FormCartItemState(producto);
  }
}

class FormCartItemState extends State<FormCartItem> {

  Producto? producto = new Producto();
  FormCartItemState(this.producto);

  final _formCartItemKey = GlobalKey<FormState>();
  //final formCartItemScaffoldKey = GlobalKey<ScaffoldState>();

  CartItem cartItem = CartItem();
  double? precioCalculado;

  //Para prevenir el que se pueda dar clic varias veces al botón mientras se registr/edita
  bool _guardando = false;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 24.0),
          child: Form(
            key: _formCartItemKey,
            child: SingleChildScrollView(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Cantidad', style: TextStyle(fontSize: 20.0)),
                  Text(producto!.nombre!),
                  SizedBox(height: 20),
                  _crearDetalles(),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _crearCantidad()),
                      SizedBox(width: 10.0),
                      Text( (precioCalculado == null)? '\$ 0.00' : '\$ ${double.parse(precioCalculado!.toStringAsFixed(2))}'),
                    ],
                  ),
                  //SizedBox(height: 20),
                  _crearBoton(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0.0,
          child: GestureDetector(
          onTap: (){
              Navigator.of(context).pop();
          },
          child: Align(
            alignment: Alignment.topRight,
            child: CircleAvatar(
              radius: 14.0,
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ),
      ]
    );
  }

  Widget _crearDetalles() {
    return TextFormField(
      initialValue: cartItem.detalles,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal)
        ),
        labelText: 'Detalles',
        hintText: "Agrega detalles de éste producto"
      ),
      maxLength: 30,
      onSaved: (valor) => cartItem.detalles = valor!.trim(),
    );
  }

  Widget _crearCantidad() {
    return TextFormField(
      //controller: pesoController,
      initialValue: (cartItem.cantidad == null)? null : cartItem.cantidad.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(
        border: new OutlineInputBorder(
          borderSide: new BorderSide(color: Colors.teal)
        ),
        hintText: (producto!.precioPorUnidad != null)? 'Unidades' : '0.5 kilos = 1 Medio',
        labelText: (producto!.precioPorUnidad != null)? 'Número de Piezas' : 'Cantidad en kilos',
        //errorText: 'Escribe el \$',
        labelStyle: TextStyle()
      ),
      maxLength: 5,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Escribe una cantidad';
        }
        if (double.tryParse(value) != null && double.parse(value) <= 0) {
          return 'Escribe una cantidad válida';
        }
        if (double.tryParse(value) == null) {
          return 'Escribe una cantidad numérica';
        }
        return null;
      },
      onSaved: (valor) {
        if(valor != null && valor.isNotEmpty && double.tryParse(valor) != null) {
          cartItem.cantidad = double.parse(valor);
        }
      },
      onChanged: (value) {
        double cantidad;
        if(value.isEmpty || double.tryParse(value) == null) {
          cantidad = 0;
        } else {
          cantidad = double.parse(value);
        }
        setState(() {
          cartItem.cantidad = cantidad;
          _calcularPrecio(cantidad);
        });
      },
    );
  }

  _calcularPrecio(double cantidad) {
    // if (cantidad == null) {
    //   precioCalculado = 0;
    // } else {
      if (producto!.precioPorUnidad != null) {
        precioCalculado = (producto!.precioPorUnidad! * cartItem.cantidad!);
      } else {
        //Calcular el precio total para este producto con base en la cantidad
        if (producto!.precioPorK != null) {
          precioCalculado = (producto!.precioPorK! * cartItem.cantidad!);
        } else if (producto!.precioPorMedio != null) {
          precioCalculado = ((producto!.precioPorMedio! * 2) * cartItem.cantidad!);
        } else if (producto!.precioPorCuarto != null) {
          precioCalculado = ((producto!.precioPorCuarto! * 4) * cartItem.cantidad!);
        }
      }
    //}

    cartItem.precio = double.parse(precioCalculado!.toStringAsFixed(2));
  }

  Widget _crearBoton() {
    return ElevatedButton.icon(
      label: Text('Agregar al pedido'),
      icon: Icon(Icons.add_shopping_cart),
      onPressed: ( _guardando )? null : _submit,
    );
  }

  void _submit() async {
    //Si el form no pasa las validaciones
    if (!_formCartItemKey.currentState!.validate() ) return;

    //Dispara los onSaved de todos los inputs del formulario
    _formCartItemKey.currentState!.save();

    setState(() { _guardando = true; });

    try {
      //Regresar el cartItem creado
      cartItem.nombreProducto = producto!.nombre;
      cartItem.idProducto = producto!.id;
      Navigator.pop(context, cartItem);
    } on Exception catch (e) {
      print(e.toString());
    } finally {
      setState(() { _guardando = false; });
    }
  }

}