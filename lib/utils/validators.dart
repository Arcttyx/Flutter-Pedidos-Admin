
class Validators {

  static bool checkCorreo(String correo) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern as String);

    return regExp.hasMatch(correo.trim());
  }

  static bool checkPassword(valor) {
    Pattern pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
    RegExp regExp = new RegExp(pattern as String);
    return regExp.hasMatch(valor);
  }

  static bool checkAlMenos2Palabras(valor) {
    Pattern pattern = r'(\w.+\s).+';
    RegExp regExp = new RegExp(pattern as String);
    return regExp.hasMatch(valor.trim());
  }

  static bool checkTelefono(valor) {
    Pattern pattern = r'^[0-9]{2}\d{8}$';
    RegExp regExp = new RegExp(pattern as String);
    return regExp.hasMatch(valor.trim());
  }
}