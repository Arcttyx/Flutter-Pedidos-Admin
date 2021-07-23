import 'package:flutter/foundation.dart';

class ProductosProvider extends ChangeNotifier {

  void updateProducts() {
    notifyListeners();
  }
}