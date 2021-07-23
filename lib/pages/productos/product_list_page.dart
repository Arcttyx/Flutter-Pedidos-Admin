
import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/producto.dart';
import 'package:mercadito_a_distancia/pages/productos/product_list_item.dart';
import 'package:mercadito_a_distancia/providers/productos_provider.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:provider/provider.dart';
import 'package:mercadito_a_distancia/utils/utils.dart' as utils;

class ProductListPage extends StatefulWidget {
  static const String id = 'product_list_page';

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  TextEditingController _buscadorTextController = TextEditingController();

  void dispose() {
    _buscadorTextController.dispose();
    super.dispose();
  }

  @override
  void initState() { 
    super.initState();
    
    mostrarUltimo();
  }

  void mostrarUltimo() async {
    final repositorio = Provider.of<DataRepository>(context, listen: false);
    Producto? ultimoInsertado = await repositorio.getLastInsertedProductoDBLocal();

    print(ultimoInsertado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Catálogo de Productos'),
      ),
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
                  hintText: 'Busca un producto',
                ),
                onChanged: (value) {
                  setState(() { });
                },
              ),
            ),
            productsList()
          ],
        ),
      ),
      floatingActionButton: Provider.of<UsuarioProvider>(context).usuario!.rol == rolAdmin? _crearFloatingActionButton(context) : null,
    );
  }

  Widget _crearFloatingActionButton(BuildContext context) {
    return Container(
      height: 70.0,
      width: 70.0,
      margin: EdgeInsets.only(bottom: 30.0, right: 20.0),
      child: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.6),
        child: Icon(Icons.add, size: 40.0),
        onPressed: () {
          Navigator.pushNamed(context, 'product_form');
        },
      ),
    );
  }

  //ToDo: Pasar a Stateless usando un bloc o algo para filtrar la lista
  Widget productsList() {
    final repositorio = Provider.of<DataRepository>(context, listen: false);

    return Consumer<ProductosProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<List<Producto>>(
            future: repositorio.getProductosDBLocalList(),
            builder: (BuildContext context, AsyncSnapshot<List<Producto>> productosSnapshot) {
              if (!productosSnapshot.hasData || productosSnapshot.hasError) {
                return Center(
                  child: (productosSnapshot.hasError)? Text('Error: ${productosSnapshot.error}') : CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent),
                );
              }

              List<Producto> productos = [];
              for (var i = 0; i < productosSnapshot.data!.length; i++) {
                //Si cumple la condición de búsqueda, se agrega a la lista de productos
                if ((_buscadorTextController.text.isEmpty || utils.valuewithoutDiacritics(productosSnapshot.data![i].nombre)!.toLowerCase().contains(utils.valuewithoutDiacritics(_buscadorTextController.text)!.toLowerCase()))) {
                  productos.add(productosSnapshot.data![i]);
                }
              }
              return Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  itemCount: productos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProductItem(
                      item: productos[index],
                      onTap: () {
                        Navigator.pushNamed(context, 'product_form', arguments: productos[index]);
                      },
                    );
                  },
                ),
              );

            },
          );
        }
    );
  }
}