import 'package:shared_preferences/shared_preferences.dart';

//Clase que centraliza las preferencias del usuario a traves de un patró Singleton
class Preferencias {
  Preferencias._();
  static final instance = Preferencias._();

  //Permite conocer, consumir las preferencias de manera centralizada
  SharedPreferences? _prefs;

  //To prevent from creating an prefs object again and again we can use this
  Future<SharedPreferences?> get prefs async {
    if (_prefs != null) return _prefs;
    _prefs = await initPrefs();
    return _prefs;
  }

  //Se inicializa el objeto que guardará las preferencias en el método
  //init porque es un Future y The await expression can only be used in an async function.
  Future<SharedPreferences> initPrefs() async {
    return this._prefs = await SharedPreferences.getInstance();
  }

  // //Getters y setters de las preferencias que se utilizarán en este proyecto
  String get fechaUltimaConsultaTablaProductos {
    // Si no hay un valor de ultima fecha, se inicializa desde la creación de la app
    // ISO 8601 Date and Time Format 
    return _prefs!.getString('fecha_ultima_consulta_tabla_productos') ?? DateTime(2021, 1, 1).toIso8601String();
  }

  set fechaUltimaConsultaTablaProductos(String fechaUltimaConsulta){
    // ISO 8601 Date and Time Format 
    _prefs!.setString('fecha_ultima_consulta_tabla_productos', fechaUltimaConsulta);
  }

  String get fechaUltimaConsultaTablaPedidos {
    // Si no hay un valor de ultima fecha, se inicializa desde la creación de la app
    // ISO 8601 Date and Time Format 
    return _prefs!.getString('fecha_ultima_consulta_tabla_pedidos') ?? DateTime(2021, 1, 1).toIso8601String();
  }

  set fechaUltimaConsultaTablaPedidos(String fechaUltimaConsulta){
    // ISO 8601 Date and Time Format 
    _prefs!.setString('fecha_ultima_consulta_tabla_pedidos', fechaUltimaConsulta);
  }

  String get fechaUltimaConsultaTablaPuntos {
    // Si no hay un valor de ultima fecha, se inicializa desde la creación de la app
    // ISO 8601 Date and Time Format 
    return _prefs!.getString('fecha_ultima_consulta_tabla_puntos') ?? DateTime(2021, 1, 1).toIso8601String();
  }

  set fechaUltimaConsultaTablaPuntos(String fechaUltimaConsulta){
    // ISO 8601 Date and Time Format 
    _prefs!.setString('fecha_ultima_consulta_tabla_puntos', fechaUltimaConsulta);
  }
}