import 'package:flutter/material.dart';

bool isNumeric(String s) {
  if (s.isEmpty) {
    return false;
  }

  final n = num.tryParse(s);
  return (n == null)? false : true;
}

String? valuewithoutDiacritics(String? str) {
  var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz'; 

  for (int i = 0; i < withDia.length; i++) {      
    str = str!.replaceAll(withDia[i], withoutDia[i]);
  }
  return str;
}

//Utilizado para mostrar unmnesaje de alerta en caso de que ocurriera un error al enviar el correo
Future<void> mostrarAlertaFuture(BuildContext context, String mensaje) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(''),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            child: Text('Aceptar'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    }
  );
}

Future<bool?> mostrarConfirmar(BuildContext context, titleMsg, contentMsg, negativeOption, positiveOption) {
  return showDialog(
    context: context,
    builder: (context) => new AlertDialog(

      title: new Text(titleMsg, style: TextStyle(color: Theme.of(context).primaryColor)),
      content: new Text(contentMsg),
      buttonPadding: EdgeInsets.symmetric(horizontal: 20),
      actions: <Widget>[
        ElevatedButton.icon(
          label: Text(negativeOption),
          icon: Icon(Icons.arrow_back_outlined),

          onPressed: () {
            Navigator.of(context).pop(false);
          }
        ),
        ElevatedButton.icon(
          label: Text(positiveOption),
          icon: Icon(Icons.check),

          onPressed: () {
            Navigator.of(context).pop(true);
          }
        ),
      ],
    ),
  );
}