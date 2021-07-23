import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/usuario.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:mercadito_a_distancia/utils/validators.dart';
import 'package:provider/provider.dart';

import '../../widgets/modal_progress_overlay_widget.dart';
import '../../widgets/form_widgets/select_dropdown_option_widget.dart';

// Create a Form widget.
class FormUserPage extends StatefulWidget with Validators {
  //Screen key
  static const String id = 'form_user';

  @override
  FormUserPageState createState() {
    return FormUserPageState();
  }
}

class FormUserPageState extends State<FormUserPage> {
  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Show Overlay while saving data
  late ProgressOverlayHandler _loadingHandler;
  ModalRoundedProgressOverlay? progressBar;

  //Prevent multiple taps over save button
  bool _guardando = false;

  //Object to save
  Usuario? user = new Usuario();

  @override
  void initState() { 
    super.initState();

    user = Provider.of<UsuarioProvider>(context, listen: false).usuario;
    print(user);

    //Configure overlay
    progressBar = ModalRoundedProgressOverlay(
      handleCallback: (ProgressOverlayHandler handler) { _loadingHandler = handler;},
      message: 'Guardando...',
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Construyendo user Form');

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi perfil'),
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
                    //_crearEmail(),
                    _crearRol(),
                    //_crearActivoInactivo(),
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
      initialValue: user!.nombre,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Nombre del usuario',
        icon: Icon(Icons.label_important, color: Colors.redAccent)
      ),
      maxLength: 50,
      validator: (valor) {
        if (valor!.length < 3) {
          return 'Ingrese el nombre';
        }
        return null;
      },
      onSaved: (valor) => user!.nombre = valor,
    );
  }

  // Widget _crearEmail() {
  //   return TextFormField(
  //     textCapitalization: TextCapitalization.words,
  //     keyboardType: TextInputType.emailAddress,
  //     decoration: InputDecoration(
  //       labelText: 'Correo electrónico',
  //       icon: Icon(Icons.label_important, color: Colors.redAccent)
  //     ),
  //     maxLength: 30,
  //     validator: (valor) {
  //       if (!Validators.checkCorreo(valor)) {
  //         return 'Ingrese un correo válido';
  //       }
  //       return null;
  //     },
  //     onSaved: (valor) => user.email = valor,
  //   );
  // }

  Widget _crearRol() {
    return Row(
      children: <Widget>[
        Icon(Icons.label_important, color: Colors.redAccent),
        SizedBox(width: 16),
        Expanded(
          child: SelectDropDownOption(
            value: user!.rol?? '',
            options: rolesUsuarios,
            onChanged: (newValue) {
              if (newValue != null) {
                //get and assing the value selected
                user!.rol = newValue;
              }
            },
            hintText: 'Selecciona el rol del usuario',
            errorText: 'Selecciona el rol del usuario',
          ),
        ),
      ],
    );
    // return Row(
    //   //mainAxisAlignment: MainAxisAlignment.center,
    //   children: <Widget>[
    //     Icon(Icons.label_important, color: Colors.redAccent, ),
    //     SizedBox(width: 16),
    //     Expanded(
    //       child: DropdownButtonFormField<String>(
    //         value: user.rol,
    //         hint: Text('Selecciona el rol del usuario'),
    //         items: rolesUsuarios.map((String rol) {
    //           return DropdownMenuItem<String>(
    //             value: rol,
    //             child: Text(rol),
    //           );
    //         }).toList(),
    //         onChanged: (valor) => setState((){
    //           user.rol = valor;
    //         }),
    //         validator: (value) => value == null ? 'Selecciona el rol del usuario' : null,
    //       ),
    //     ),
    //   ],
    // );
  }

  // Widget _crearActivoInactivo() {
  //   return Container(
  //     child: SwitchListTile(
  //       contentPadding: EdgeInsets.zero,
  //       activeTrackColor: Colors.cyan,
  //       inactiveTrackColor: Colors.red,
  //       inactiveThumbColor: Colors.red,
  //       activeColor: Colors.cyan,
  //       value: user.activo,
  //       title: Center(child: Text('Inactivo / Activo')),
  //       secondary: IconButton(
  //         padding: EdgeInsets.zero,
  //         constraints: BoxConstraints(
  //           minWidth: kMinInteractiveDimension - 8,
  //           minHeight: kMinInteractiveDimension,
  //         ),
  //         alignment: Alignment.centerLeft,
  //         icon: Icon(Icons.label_important, color: Colors.redAccent),
  //         onPressed: null,
  //       ),
  //       onChanged: (valor) => setState((){
  //         user.activo = valor;
  //       })
  //     ),
  //   );
  // }

  Widget _crearBotonGuardar() {
    return Center(
      child: ElevatedButton.icon(
        label: Text('Guardar'),
        icon: Icon(Icons.save),
        onPressed: () {
          if ( !_guardando ){ _submit(); }
        }
      ),
    );
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

    print('Todo chido con el user!');
    print(user);

    try {
      final repositorio = Provider.of<DataRepository>(context, listen: false);
      bool resultado = true;

      resultado = await repositorio.editUsuario(user);
      //await Future.delayed(Duration(seconds: 3));

      if (resultado) {
        //Actualizar usuario en Provider y regresar a Home
        Provider.of<UsuarioProvider>(context, listen: false).setUsuario(user);
        user = Usuario();
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