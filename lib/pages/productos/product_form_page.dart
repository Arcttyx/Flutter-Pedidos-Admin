import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/producto.dart';
import 'package:mercadito_a_distancia/providers/productos_provider.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:mercadito_a_distancia/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mercadito_a_distancia/utils/utils.dart' as utils;
import 'package:provider/provider.dart';

import '../../widgets/modal_progress_overlay_widget.dart';
import '../../widgets/form_widgets/on_off_switch_widget.dart';
import '../../widgets/form_widgets/select_dropdown_option_widget.dart';
import '../../widgets/form_widgets/measurement_units_chips_widget.dart';

class FormProduct extends StatefulWidget with Validators {
  static const String id = 'product_form';

  @override
  FormProductState createState() {
    return FormProductState();
  }
}

class FormProductState extends State<FormProduct> {
  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Show Overlay while saving data
  late ProgressOverlayHandler _loadingHandler;
  ModalRoundedProgressOverlay? progressBar;

  //Prevent multiple taps over save button
  bool _guardando = false;

  //creation/update operations flag
  bool _esEdicion = false;

  //Object to save
  Producto product = new Producto();

  //Current logged in user
  final _auth = auth.FirebaseAuth.instance;
  auth.User? loggedInUser;

  //Default values for form input's
  bool unitKiloSelected = true;
  bool unitMedioSelected = false;
  bool unitCuartoSelected = false;
  bool unitEnteraSelected = false;

  @override
  void initState() { 
    super.initState();
    loggedInUser = _auth.currentUser;

    //Configure overlay
    progressBar = ModalRoundedProgressOverlay(
      handleCallback: (ProgressOverlayHandler handler) { _loadingHandler = handler;},
      message: 'Guardando...',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //Setting current object to save depending creating/update operation
    Producto? _productFromList = ModalRoute.of(context)!.settings.arguments as Producto?;
    if (_productFromList != null) {
      product = _productFromList;
      _esEdicion = true;

      unitKiloSelected = product.categoriasUnidades!.contains(unidadKilo);
      unitMedioSelected = product.categoriasUnidades!.contains(unidadMedioKilo);
      unitCuartoSelected = product.categoriasUnidades!.contains(unidadCuartoKilo);
      unitEnteraSelected = product.categoriasUnidades!.contains(unidadEntera);
    } else {
      //Si se va a crear un producto se indica que el kilo esta activado por default
      //Se pone aqui porque si no cada vez que se reconstruye el widget se agregaría a las categorías
      if (!product.categoriasUnidades!.contains(unidadKilo)) {
        product.categoriasUnidades!.add(unidadKilo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( _esEdicion? 'Edición de producto' : 'Registro de producto'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15.0),
              color: Colors.white70,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _crearNombre(),
                    _crearCategoriasUnidades(),
                    _crearCategoria(),
                    SizedBox(height: 20.0),
                    _crearDescripcion(),
                    _crearActivoInactivo(),
                    SizedBox(height: 20),
                    _crearBotonesGuardar()
                  ],
                ),
              ),
            ),
          ),
          progressBar!
        ]
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: product.nombre,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Nombre del producto',
        icon: Icon(Icons.label_important, color: Colors.redAccent)
      ),
      maxLength: 50,
      validator: (valor) {
        if (valor!.length < 3) {
          return 'Ingrese el nombre';
        }
        return null;
      },
      onSaved: (valor) => product.nombre = valor,
    );
  }

  Widget _crearCategoriasUnidades() {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Unidades de medida',
            labelStyle: TextStyle(color: Colors.black54),
            icon: Icon(Icons.label_important, color: Colors.redAccent),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.only(bottom: 0),
            errorStyle: TextStyle(
              color: Theme.of(context).errorColor, // Por el disabled no pone el color del error por default
            ),
          ),
          readOnly: true,
          enabled: false,
          validator: (value) {
            return product.categoriasUnidades!.isEmpty ? 'Selecciona al menos una unidad de medida' : null;
          }
        ),
        MeasurementUnitsChips(
          isKiloSelected: unitKiloSelected,
          isUnidadSelected: unitEnteraSelected,
          textFieldKilo: _crearPrecioPorK() as TextFormField,
          textFieldUnidad: _crearPrecioPorUnidad() as TextFormField,
          onKiloSelected: (newkiloSelectedValue) {
            if (newkiloSelectedValue != null) {
              if (newkiloSelectedValue) {
                if (!product.categoriasUnidades!.contains(unidadKilo)) {
                  product.categoriasUnidades!.add(unidadKilo);
                }
                product.categoriasUnidades!.removeWhere((item) => item == unidadEntera);
                product.precioPorUnidad = null;
                unitEnteraSelected = false;
              } else {
                product.categoriasUnidades!.removeWhere((item) => item == unidadKilo);
                product.precioPorK = null;
              }

              unitKiloSelected = newkiloSelectedValue;
            }
          },
          onUnidadSelected: (newUnidadSelectedValue) {
            if (newUnidadSelectedValue) {
              if (newUnidadSelectedValue) {
                //Si se selecciona Unidad, las otras categorías no deben mostrarse ni guardarse
                if (!product.categoriasUnidades!.contains(unidadEntera)) {
                  product.categoriasUnidades!.add(unidadEntera);
                }
                product.categoriasUnidades!.removeWhere((item) => [unidadKilo, unidadMedioKilo, unidadCuartoKilo].contains(item));
                product.precioPorK = null;
                unitKiloSelected = false;
              } else {
                //Si se deselecciona Unidad, las otras categorías no deben mostrarse ni guardarse
                product.categoriasUnidades!.remove(unidadEntera);
                product.precioPorUnidad = null;
              }

              unitEnteraSelected = newUnidadSelectedValue;
            }
          },
        )
      ],
    );
  }

  Widget _crearPrecioPorK() {
    return TextFormField(
      initialValue: (product.precioPorK == null)? null : product.precioPorK.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(
        border: new OutlineInputBorder(
          borderSide: new BorderSide(color: Colors.teal)
        ),
        hintText: '\$',
        labelText: '\$ por kilo',
        labelStyle: TextStyle()
      ),
      maxLength: 5,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Escribe el precio';
        }
        if (double.tryParse(value) != null && double.parse(value) <= 0) {
          return 'Escribe un precio válido';
        }
        if (double.tryParse(value) == null) {
          return 'Escribe un precio válido';
        }
        return null;
      },
      onSaved: (valor) {
        if(valor != null && valor.isNotEmpty && double.tryParse(valor) != null) {
          product.precioPorK = double.parse(valor);
        }
      },
    );
  }

  Widget _crearPrecioPorUnidad() {
    return TextFormField(
      initialValue: (product.precioPorUnidad == null)? '' : product.precioPorUnidad.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        border: new OutlineInputBorder(
          borderSide: new BorderSide(color: Colors.teal)
        ),
        hintText: '\$',
        labelText: '\$ por Unidad',
      ),
      maxLength: 5,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Escribe el precio';
        }
        if (double.tryParse(value) != null && double.parse(value) <= 0) {
          return 'Escribe un precio válido';
        }
        if (double.tryParse(value) == null) {
          return 'Escribe un precio válido';
        }
        return null;
      },
      onSaved: (valor) {
        if(valor != null && valor.isNotEmpty && double.tryParse(valor) != null) {
          product.precioPorUnidad = double.parse(valor);
        }
      },
    );
  }

  Widget _crearCategoria() {
    return Row(
      children: <Widget>[
        Icon(Icons.label_important, color: Colors.redAccent),
        SizedBox(width: 16),
        Expanded(
          child: SelectDropDownOption(
            value: product.categoria,
            options: categoriasProductos,
            onChanged: (newValue) {
              //get and assing the value selected
              if (newValue != null) {
                product.categoria = newValue;
              }
            },
            hintText: 'Selecciona la categoría del producto',
            errorText: 'Selecciona la categoría del producto',
          ),
        ),
      ],
    );
  }

  Widget _crearDescripcion() {
    return TextFormField(
      initialValue: product.descripcion,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal)
        ),
        labelText: 'Descripción',
        icon: Icon(Icons.label_important, color: Colors.blueAccent),
        hintText: "Ingresa tu descripción"
      ),
      maxLength: 50,
      maxLines: 2,
      onSaved: (valor) => product.descripcion = valor,
    );
  }

  Widget _crearActivoInactivo() {
    return Container(
      child: OnOffSwitch(
        value: product.disponible,
        onChanged: (newValue) {
          if (newValue != null) {
            //get and assing the active/inactive value
            product.disponible = newValue;
          }
        },
        title: 'No disponible / En existencia',
        icon: Icon(Icons.label_important, color: Colors.redAccent),
      ),
    );
  }

  Widget _crearBotonesGuardar() {
    if (Provider.of<UsuarioProvider>(context).usuario!.rol == rolAdmin) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: ElevatedButton.icon(
              label: Text('Guardar y \nSalir', textAlign: TextAlign.center),
              icon: Icon(Icons.save),
              onPressed: () {
                if ( !_guardando ){ _submit(true); }
              }
            ),
          ),
          Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 5,
            child: ElevatedButton.icon(
              label: Text('Guardar y \nNuevo', textAlign: TextAlign.center),
              icon: Icon(Icons.save),
              onPressed: () {
                if ( !_guardando ){ _submit(false); }
              }
            ),
          )
        ],
      );
    } else {
      return Container();
    }
  }

  void _submit(bool regresarALista) async {
    //Si el form no pasa las validaciones
    if (!_formKey.currentState!.validate() ) return;

    if(loggedInUser == null) {
      utils.mostrarAlertaFuture(context, sesionNoIniciada);
      return;
    }

    //Avoid double save button tap and Show overlay before save
    _guardando = true;
    _loadingHandler.show();

    //Dispara los onSaved de todos los inputs del formulario
    _formKey.currentState!.save();

    try {
      final repositorio = Provider.of<DataRepository>(context, listen: false);
      bool resultado;

      //Se registra/actualiza la fecha de ultima actualización del producto
      product.ultimaActualizacion = DateTime.now();
      if (_esEdicion) {
        resultado = await repositorio.upsertProductos([product]);
      } else {
        //Se registra el id que usará el nuevo regitro
        Producto? ultimoInsertado = await repositorio.getLastInsertedProductoDBLocal();
        if (ultimoInsertado != null) {
          product.id = ((int.tryParse(ultimoInsertado.id!) ?? 0) + 1).toString();
        } else {
          product.id = '1';
        }
        resultado = await repositorio.upsertProductos([product]);
      }

      if (resultado) {
        Provider.of<ProductosProvider>(context, listen: false).updateProducts();

        if (!_esEdicion) {
          product = Producto();
        }

        if (regresarALista) {
          Navigator.of(context).pop();
        } else {
          Navigator.popAndPushNamed(context, 'product_form');
        }
      }

    } on Exception catch (e) {
      print(e);
    } finally {
      _guardando = false;
      _loadingHandler.dismiss();
    }
  }
}