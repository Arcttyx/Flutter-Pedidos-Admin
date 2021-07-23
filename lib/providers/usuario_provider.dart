import 'package:flutter/foundation.dart';
import 'package:mercadito_a_distancia/models/usuario.dart';

class UsuarioProvider extends ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  void setUsuario(Usuario? usuario) {
    this._usuario = usuario;
    notifyListeners();
  }

  @override
  String toString() {
    return _usuario.toString();
  }
}