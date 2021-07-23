import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/usuario.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/utils/validators.dart';
import 'package:provider/provider.dart';

import '../widgets/modal_progress_overlay_widget.dart';
import 'loading_page.dart';

class RegisterPage extends StatefulWidget with Validators {
  //Screen key
  static const String id = 'register_page';

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;

  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Show Overlay while saving data
  late ProgressOverlayHandler _loadingHandler;
  late ModalRoundedProgressOverlay progressBar;

  //Data to be saved
  String? email;
  String? password;
  String? nombreUser;

  //Prevent multiple taps over save button
  bool _guardando = false;

  @override
  void initState() { 
    super.initState();

    //Configure overlay
    progressBar = ModalRoundedProgressOverlay(
      handleCallback: (ProgressOverlayHandler handler) { _loadingHandler = handler;},
      message: 'Registrando...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _crearFondo(context),
          _loginForm(context),
          progressBar
        ],
      ),
    );
  }

  Widget _crearFondo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    final fondoColor = Container(
      height: size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/mercado1.jpg'),
          fit: BoxFit.fitWidth
        ),
        gradient: LinearGradient(
          colors: <Color> [
            Color.fromRGBO(0, 0, 0, 1.0),
            Theme.of(context).primaryColor
          ]
        )
      ),
    );

    return Stack(
      children: <Widget>[
        fondoColor,
        Container(
          padding: EdgeInsets.only(top: 180.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0, width: double.infinity),
            ],
          ),
        )

      ],
    );
  }

  Widget _loginForm(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(height: 50.0),
              Container(
                width: size.width * 0.85,
                margin: EdgeInsets.symmetric(vertical: 30.0),
                padding: EdgeInsets.symmetric(vertical:50.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: <BoxShadow> [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3.0,
                      offset: Offset(0.0, 5.0),
                      spreadRadius: 3.0
                    )
                  ]
                ),
                child: Column(
                  children: <Widget>[
                    Text('Registro', style: TextStyle(fontSize: 20.0)),
                    SizedBox(height: 40.0),
                    _crearNombreUser(),
                    _crearEmail(),
                    _crearPassword(),
                    SizedBox(height: 25.0),
                    _crearBoton(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearNombreUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        //initialValue: product.nombre,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          labelText: 'Nombre de usuario',
          icon: Icon(Icons.label_important, color: Colors.redAccent)
        ),
        //autofocus: true,
        maxLength: 15,
        validator: (valor) {
          if (valor!.length < 5) {
            return 'Ingrese un nombre para identificarle';
          }
          return null;
        },
        onSaved: (valor) => nombreUser = valor,
      ),
    );
  }

  Widget _crearEmail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Correo electrónico',
          icon: Icon(Icons.label_important, color: Colors.redAccent)
        ),
        maxLength: 30,
        validator: (valor) {
          if (!Validators.checkCorreo(valor!)) {
            return 'Ingrese un correo válido';
          }
          return null;
        },
        onSaved: (valor) => email = valor,
      ),
    );
  }

  Widget _crearPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
          icon: Icon(Icons.label_important, color: Colors.redAccent)
        ),
        maxLength: 20,
        validator: (valor) {
          if (valor!.length < 6) {
            return 'Ingrese mínimo 6 caracteres';
          }
          return null;
        },
        onSaved: (valor) => password = valor,
      ),
    );
  }

  Widget _crearBoton() {
    return ElevatedButton(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0),
        child: Text('Crear cuenta'),
      ),
      onPressed: () {
        if ( !_guardando ){ _submit(); }
      }
    );
  }

  void _submit() async {
    print("Creando cuenta");
    //Si el form no pasa las validaciones
    if (!_formKey.currentState!.validate() ) return;

    //Avoid double save button tap and Show overlay before save
    _guardando = true;
    _loadingHandler.show();

    //Dispara los onSaved de todos los inputs del formulario
    _formKey.currentState!.save();

    try {
      await _auth.createUserWithEmailAndPassword(email: email!, password: password!)
      .then( (userCredentials) async {
        //Actualizar el nombre del usuario
        await userCredentials.user!.updateProfile(displayName: nombreUser);

        if (userCredentials.user != null) {
          Usuario usuarioAGuardar = Usuario(idAuth: userCredentials.user!.uid, idDoc: userCredentials.user!.uid, email: email, nombre: nombreUser, rol: rolConsulta, activo: true);
          //final newUserBD = await FirebaseFirestore.instance.collection(kUsersCollection)
          await FirebaseFirestore.instance.collection(kUsersCollection)
          .doc(userCredentials.user!.uid)
          .set(usuarioAGuardar.toJson())
          .catchError((error) { print("Failed to add user: $error"); });

          Provider.of<UsuarioProvider>(context, listen: false).setUsuario(usuarioAGuardar);

          Navigator.pushReplacementNamed(context, LoadingPage.id);
        }
      })
      .catchError((e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Ha ocurrido un erro en el registro, intenta más tarde"),
              content: Text(e.message),
              actions: [
                TextButton(
                  child: Text("Aceptar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      });
    } catch(e) {
      print(e.toString());
    } finally {
      //Enable save button and Hide overlay after save or error
      _guardando = false;
      _loadingHandler.dismiss();
    }
  }
}