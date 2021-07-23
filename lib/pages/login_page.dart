import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/constants.dart';
import 'package:mercadito_a_distancia/models/usuario.dart';
import 'package:mercadito_a_distancia/providers/usuario_provider.dart';
import 'package:mercadito_a_distancia/services/data_repository.dart';
import 'package:mercadito_a_distancia/utils/validators.dart';
import 'package:provider/provider.dart';

import '../widgets/modal_progress_overlay_widget.dart';
import 'loading_page.dart';

class LoginPage extends StatefulWidget with Validators {
  //Screen key
  static const String id = 'login_page';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  //For form validation
  final _formKey = GlobalKey<FormState>();

  //Show Overlay while saving data
  late ProgressOverlayHandler _loadingHandler;
  late ModalRoundedProgressOverlay progressBar;

  //Data to be saved
  String? email;
  String? password;
  bool obscurePassword = true;

  //Prevent multiple taps over save button
  bool _guardando = false;

  @override
  void initState() { 
    super.initState();

    //Configure overlay
    progressBar = ModalRoundedProgressOverlay(
      handleCallback: (ProgressOverlayHandler handler) { _loadingHandler = handler;},
      message: 'Iniciando sesión...',
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
              Container(height: 80.0),
              Container(
                width: size.width * 0.85,
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
                    Image.asset('assets/img/logo.png'),
                    _crearUsuario(),
                    SizedBox(height: 10.0),
                    _crearPassword(),
                    SizedBox(height: 30.0),
                    _crearBoton(),
                    SizedBox(height: 20.0),
                    Center(child:Text('Atención a clientes\n     5510101055')),
                    SizedBox(height: 30.0),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearUsuario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        textAlign: TextAlign.start,
        keyboardType: TextInputType.emailAddress,
        decoration: kTextFieldDecoration.copyWith(
          prefixIcon: Icon(Icons.person_sharp, color: Theme.of(context).primaryColor,),
          suffixIcon: null,
          hintText: 'Usuario',
          counterText: '',
        ),
        maxLength: 30,
        validator: (valor) {
          if (!Validators.checkCorreo(valor!)) { return 'Ingrese un correo válido'; }
          return null;
        },
        onSaved: (valor) => email = valor,
      ),
    );
  }

  Widget _crearPassword() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        obscureText: obscurePassword,
        textAlign: TextAlign.start,
        decoration: kTextFieldDecoration.copyWith(
          prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
          suffixIcon: IconButton(
            icon: (obscurePassword)? Icon(Icons.remove_red_eye_outlined, color: Theme.of(context).primaryColor) : Icon(Icons.remove_red_eye, color: Theme.of(context).primaryColor),
            onPressed: () { setState(() {
              obscurePassword = !obscurePassword;
            });
          }),
          hintText: 'Constraseña',
          counterText: '',
        ),
        maxLength: 20,
        validator: (valor) {
          if (valor!.length == 0) { return 'Ingrese su contraseña'; }
          if (valor.length < 6) { return 'Ingrese mínimo 6 caracteres'; }
          return null;
        },
        onSaved: (valor) => password = valor,
      ),
    );
  }

  Widget _crearBoton() {
    return ElevatedButton(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 60.0, vertical: 10.0),
        child: Text('Iniciar sesión', style: TextStyle(fontSize: 20)),
      ),
      onPressed: () {
        if ( !_guardando ){ _submit(); }
      }
    );
  }

  void _submit() async {
    //Si el form no pasa las validaciones
    if (!_formKey.currentState!.validate() ) return;

    //Avoid double save button tap and Show overlay before save
    _guardando = true;
    _loadingHandler.show();

    //Dispara los onSaved de todos los inputs del formulario
    _formKey.currentState!.save();

    try {
      final user = await _auth.signInWithEmailAndPassword(email: email!, password: password!);
      //Buscar usuario en la BD y ponerlo en el provider
      final database = Provider.of<DataRepository>(context, listen: false);
      Usuario usuarioEnBDLogueado = await database.searchUsuarioById(user.user!.uid);
      Provider.of<UsuarioProvider>(context, listen: false).setUsuario(usuarioEnBDLogueado);
      Navigator.pushReplacementNamed(context, LoadingPage.id);
    } catch (e) {
      print(e);
    } finally {
      //Enable save button and Hide overlay after save or error
      _guardando = false;
      _loadingHandler.dismiss();
    }
  }
}