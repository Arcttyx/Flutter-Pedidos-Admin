import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/models/cart_item.dart';

class ListCartItem extends StatefulWidget {
  ListCartItem({required this.item, this.onDeleteCreate, this.onDeleteUpdate, this.esEdicion = false, this.esEditable = true, this.unidadMedida = ''});

  final CartItem item;
  final void Function()? onDeleteCreate;
  final void Function(bool?)? onDeleteUpdate;
  final bool esEdicion;
  final bool esEditable;
  final String unidadMedida;

  @override
  _ListCartItemState createState() => _ListCartItemState();
}

class _ListCartItemState extends State<ListCartItem> {

  @override
  Widget build(BuildContext context) {
    //print('En ListCartItem - Construyendo producto item');
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Column(
          children: [
            ListTile(
              //leading: Icon(Icons.shopping_basket),
              title: _crearTitulo(),
              trailing: (widget.esEdicion)?
                Checkbox(
                  value: (widget.item.disponible != null)? widget.item.disponible : true,
                  onChanged: (widget.esEditable && widget.onDeleteUpdate != null)? widget.onDeleteUpdate : null,
                )
                :
                IconButton(
                    icon: Icon(Icons.delete_forever_outlined, color: Colors.red),
                    onPressed: widget.onDeleteCreate?? null,
                ),
              onTap: null
            ),
          ],
        ),
      )
    );
  }

  Widget _crearTitulo() {
    bool estaDisponible = (widget.item.disponible != null)? widget.item.disponible! : true;
    TextStyle estiloDisponible = TextStyle(decoration: (!estaDisponible)? TextDecoration.lineThrough: null);
    //String unidad = (widget.unidadMedida != null && widget.unidadMedida.isNotEmpty)? ' ${widget.unidadMedida} de ' : ' ';
    String unidad = (widget.unidadMedida.isNotEmpty)? ' ${widget.unidadMedida} de ' : ' ';
    List<Text> titulos = [Text('${widget.item.cantidad}$unidad${widget.item.nombreProducto}', style: estiloDisponible)];

    if (widget.item.detalles != null && widget.item.detalles!.isNotEmpty) {
      titulos.add(Text('(${widget.item.detalles})', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14.0, decoration: (!estaDisponible)? TextDecoration.lineThrough: null)));
    }

    titulos.add(Text((widget.item.precio == null)? '\$ 0.00' : '\$ ${widget.item.precio}', style: estiloDisponible));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: titulos,
    );
  }
}