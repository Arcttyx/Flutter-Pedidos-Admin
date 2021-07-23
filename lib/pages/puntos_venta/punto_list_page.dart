import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';
import 'package:mercadito_a_distancia/pages/puntos_venta/punto_list_item.dart';
import 'package:mercadito_a_distancia/providers/puntos_venta_provider.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:provider/provider.dart';
import 'package:mercadito_a_distancia/utils/utils.dart' as utils;

class PuntoVentaListPage extends StatefulWidget {
  static const String id = 'punto_list_page';

  @override
  _PuntoVentaListPageState createState() => _PuntoVentaListPageState();
}

class _PuntoVentaListPageState extends State<PuntoVentaListPage> {
  TextEditingController _buscadorTextController = TextEditingController();

  late List<PuntoVenta> puntos;
  Map<int, bool> selectedItems = {};
  bool isSelectionMode = false;

  void dispose() {
    _buscadorTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Puntos de venta'),
        actions: _buildSelectAllButton(),
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
                  hintText: 'Busca un punto de venta',
                ),
                onChanged: (value) {
                  setState(() { });
                },
              ),
            ),
            puntosList()
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
          Navigator.pushNamed(context, 'form_punto_venta');
        },
      ),
    );
  }

  List<Widget>? _buildSelectAllButton() {
    // The button will be visible when the selectionMode is enabled. 
    if (isSelectionMode) {
      final repositorio = Provider.of<DataRepository>(context, listen: false);
      bool isFalseAvailable = selectedItems.containsValue(false);  // check if all item is not selected
      bool isTrueAvailable = selectedItems.containsValue(true);  // check if any item is selected
      
      // Widget deleteBtn = InkWell(
      //   onTap: isTrueAvailable? () {
      //     final filteredMap = Map.from(selectedItems)..removeWhere((k, v) => v == false);
      //     List<String> idsToDelete = [];
      //     for (int posPuntosList in filteredMap.keys) {
      //       if (posPuntosList < puntos.length) {
      //         idsToDelete.add(puntos[posPuntosList].id!);
      //       }
      //     }
      //     repositorio.deleteMultiplePuntosFromDB(idsToDelete);
      //     setState(() {
      //       selectedItems.updateAll((key, value) => false);
      //       isSelectionMode = selectedItems.containsValue(true);
      //     });
      //   } : null,
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       Icon(Icons.delete_forever),
      //       Text("Eliminar")
      //     ],
      //   ),
      // );
      
      Widget deleteBtn = Container(
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.delete_forever),
          onPressed: isTrueAvailable? () {
            final filteredMap = Map.from(selectedItems)..removeWhere((k, v) => v == false);
            List<String> idsToDelete = [];
            for (int posPuntosList in filteredMap.keys) {
              if (posPuntosList < puntos.length) {
                idsToDelete.add(puntos[posPuntosList].id!);
              }
            }
            repositorio.deleteMultiplePuntosFromDB(idsToDelete);
            setState(() {
              selectedItems.updateAll((key, value) => false);
              isSelectionMode = selectedItems.containsValue(true);
            });
          } : null
        ),
      );


      // Widget selectAllBtn = InkWell(
      //   onTap: () {
      //     selectedItems.updateAll((key, value) => isFalseAvailable);
      //       setState(() {
      //         //isSelectionMode = selectedItems.containsValue(true);
      //       });
      //   },
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       isFalseAvailable? Icon(Icons.library_add_check_outlined) : Icon(Icons.remove_done),
      //       Text("Selec todo")
      //     ],
      //   ),
      // );


      Widget selectAllBtn = Container(
        padding: EdgeInsets.only(right: 10.0),
        child: IconButton(
          icon: isFalseAvailable? Icon(Icons.library_add_check_outlined) : Icon(Icons.remove_done),
          onPressed: () {
            selectedItems.updateAll((key, value) => isFalseAvailable);
            setState(() {
              isSelectionMode = selectedItems.containsValue(true);
            });
          }
        ),
      );

      return [deleteBtn, selectAllBtn];
    }
    return null;
  }

  Widget puntosList() {
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

            puntos = [];
            for (var i = 0; i < puntosSnapshot.data!.length; i++) {
              //Si cumple la condición de búsqueda, se agrega a la lista de productos
              if ((_buscadorTextController.text.isEmpty || utils.valuewithoutDiacritics(puntosSnapshot.data![i].nombre)!.toLowerCase().contains(utils.valuewithoutDiacritics(_buscadorTextController.text)!.toLowerCase()))) {
                puntos.add(puntosSnapshot.data![i]);
              }
            }

            return Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                itemCount: puntos.length,
                itemBuilder: (BuildContext context, int index) {
                  
                  selectedItems[index] = selectedItems[index]?? false;
                  bool isSelected = selectedItems[index]!;

                  return PuntoVentaItem(
                    item: puntos[index],
                    onTap: () {
                      if (isSelectionMode) {
                        setState(() {
                          selectedItems[index] = !isSelected;
                          isSelectionMode = selectedItems.containsValue(true);
                        });
                      } else {
                        Navigator.pushNamed(context, 'form_punto_venta', arguments: puntos[index]);
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        selectedItems[index] = !isSelected;
                        isSelectionMode = selectedItems.containsValue(true);
                      });
                    },
                    trailing: (isSelectionMode)? Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: Theme.of(context).primaryColor) : null
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