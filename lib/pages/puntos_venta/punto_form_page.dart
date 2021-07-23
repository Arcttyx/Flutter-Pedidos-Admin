import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/punto_venta.dart';
import 'package:mercadito_a_distancia/providers/puntos_venta_provider.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:mercadito_a_distancia/utils/validators.dart';
import 'package:provider/provider.dart';

import '../../widgets/modal_progress_overlay_widget.dart';
import '../../widgets/form_widgets/on_off_switch_widget.dart';

// Create a Form widget.
class FormPuntoVenta extends StatefulWidget with Validators {
  //Screen key
  static const String id = 'form_punto_venta';

  @override
  FormPuntoVentaState createState() {
    return FormPuntoVentaState();
  }
}

class FormPuntoVentaState extends State<FormPuntoVenta> {
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
  PuntoVenta puntoVenta = new PuntoVenta();

  @override
  void initState() { 
    super.initState();

    //Configure overlay
    progressBar = ModalRoundedProgressOverlay(
      handleCallback: (ProgressOverlayHandler handler) { _loadingHandler = handler;},
      message: 'Guardando...',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('didChangeDependencies de Form Punto');
    
    PuntoVenta? puntoFromList = ModalRoute.of(context)!.settings.arguments as PuntoVenta?;
    if (puntoFromList != null) {
      puntoVenta = puntoFromList;
      print(puntoVenta);
      _esEdicion = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Construyendo punto Form');

    return Scaffold(
      appBar: AppBar(
        title: Text( _esEdicion? 'Edición de punto' : 'Registro de punto'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _crearNombre(),
                    _crearDireccion(),
                    _crearDescripcion(),
                    _crearContacto(),
                    _crearTelefono(),
                    _crearActivoInactivo(),
                    SizedBox(height: 20),
                    _crearBotonGuardar()
                  ],
                ),
              ),
            ),
          ),
          progressBar!
        ],
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: puntoVenta.nombre,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Nombre del punto',
        icon: Icon(Icons.label_important, color: Colors.redAccent)
      ),
      //autofocus: true,
      maxLength: 50,
      validator: (valor) {
        if (valor!.length < 3) {
          return 'Ingrese el nombre';
        }
        return null;
      },
      onSaved: (valor) => puntoVenta.nombre = valor,
    );
  }

  Widget _crearDireccion() {
    return TextFormField(
      initialValue: puntoVenta.direccion,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal)
        ),
        labelText: 'Dirección',
        icon: Icon(Icons.label_important, color: Colors.blueAccent),
        hintText: "Ingresa la direccion"
      ),
      maxLength: 50,
      maxLines: 2,
      onSaved: (valor) => puntoVenta.direccion = valor,
    );
  }

  Widget _crearDescripcion() {
    return TextFormField(
      initialValue: puntoVenta.descripcion,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal)
        ),
        labelText: 'Descripción',
        icon: Icon(Icons.label_important, color: Colors.blueAccent),
        hintText: "Ingresa una descripción"
      ),
      maxLength: 50,
      maxLines: 2,
      onSaved: (valor) => puntoVenta.descripcion = valor,
    );
  }

  Widget _crearContacto() {
    return TextFormField(
      initialValue: puntoVenta.contacto,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal)
        ),
        labelText: 'Contacto',
        icon: Icon(Icons.label_important, color: Colors.blueAccent),
        hintText: "Quién es el contacto en ese punto"
      ),
      maxLength: 50,
      onSaved: (valor) => puntoVenta.contacto = valor,
    );
  }

  Widget _crearTelefono() {
    return TextFormField(
      initialValue: puntoVenta.telefono,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal)
        ),
        labelText: 'Teléfono',
        icon: Icon(Icons.label_important, color: Colors.blueAccent),
        hintText: "Teléfono de contacto"
      ),
      maxLength: 12,
      onSaved: (valor) => puntoVenta.telefono = valor,
    );
  }

  Widget _crearActivoInactivo() {
    return Container(
      child: OnOffSwitch(
        value: puntoVenta.activo,
        onChanged: (newValue) {
          if (newValue != null) {
            //get and assing the active/inactive value
            puntoVenta.activo = newValue;
          }
        },
        title: 'No activo / Activo',
        icon: Icon(Icons.label_important, color: Colors.redAccent),
      ),
    );
  }

  Widget _crearBotonGuardar() {
    if (Provider.of<UsuarioProvider>(context).usuario!.rol == rolAdmin) {
      return Center(
        child: ElevatedButton.icon(
          label: Text('Guardar'),
          icon: Icon(Icons.save),
          onPressed: () {
            if ( !_guardando ){ _submit(); }
          }
        ),
      );
    } else {
      return Container();
    }
  }

  void _submit() async {
    print("Guardando");
    //Si el form no pasa las validaciones
    if (!_formKey.currentState!.validate() ) return;

    //Avoid double save button tap and Show overlay before save
    _guardando = true;
    _loadingHandler.show();

    //Dispara los onSaved de todos los inputs del formulario
    _formKey.currentState!.save();

    print('Todo chido con el punto!');
    print(puntoVenta);

    try {
      final repositorio = Provider.of<DataRepository>(context, listen: false);
      bool resultado = true;

      //Se registra/actualiza la fecha de ultima actualización del producto
      puntoVenta.ultimaActualizacion = DateTime.now();

      if (_esEdicion) {
        resultado = await repositorio.upsertPuntosVenta([puntoVenta]);
      } else {
        //Se registra el id que usará el nuevo regitro
        PuntoVenta? ultimoInsertado = await repositorio.getLastInsertedPuntoVentaDBLocal();
        if (ultimoInsertado != null) {
          puntoVenta.id = ((int.tryParse(ultimoInsertado.id!) ?? 0) + 1).toString();
        } else {
          puntoVenta.id = '1';
        }
        resultado = await repositorio.upsertPuntosVenta([puntoVenta]);
      }

      //await Future.delayed(Duration(seconds: 3));

      if (resultado) {
        Provider.of<PuntosVentaProvider>(context, listen: false).updatePuntosVenta();
        puntoVenta = PuntoVenta();
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      print('///////en el catch del try');
      print(e);
      print('en el catch del try//////////////');
      //String mensajeError = "Ha ocurrido un error, por favor, intente más tarde";
      //utils.mostrarAlerta(context, mensajeError, expiroSesion);
    } finally {
      //Enable save button and Hide overlay after save or error
      _guardando = false;
      _loadingHandler.dismiss();
    }
  }
}