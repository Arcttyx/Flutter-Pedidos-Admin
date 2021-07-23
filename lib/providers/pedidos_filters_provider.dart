import 'package:flutter/foundation.dart';
import 'package:mercadito_a_distancia/constants.dart';

class PedidosFiltersProvider extends ChangeNotifier {
  /// Internal, private state of the cart.
  //Map<String, dynamic> _filttros = {'fecha': null, 'punto' : null, 'estatus': null};
  DateTime? _fecha;
  String? _punto;
  EstatusPedido? _estatus;

  DateTime? get fecha => _fecha;
  String? get punto => _punto;
  EstatusPedido? get estatus => _estatus;

  void setFiltroFecha(DateTime fecha) {
    this._fecha = fecha;
    notifyListeners();
  }

  void setFiltroPunto(String? punto) {
    this._punto = punto;
    notifyListeners();
  }

  void setFiltroEstatus(EstatusPedido? estatus) {
    this._estatus = estatus;
    notifyListeners();
  }

  void cleanFilters() {
    _fecha = null;
    _estatus = null;
    _punto = null;
    notifyListeners();
  }

  @override
  String toString() {
    return 'estatus: ${this.estatus}, fecha: ${this.fecha}, punto: ${this.punto}';
  }
}