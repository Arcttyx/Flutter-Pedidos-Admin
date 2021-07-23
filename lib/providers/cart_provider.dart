import 'package:flutter/foundation.dart';
import 'package:mercadito_a_distancia/models/cart_item.dart';
import 'package:mercadito_a_distancia/models/pedido.dart';

class CartProvider extends ChangeNotifier {
  /// Internal, private state of the cart.
  Pedido _carritoCompras = Pedido();

  Pedido get carritoCompras => _carritoCompras;

  /// The current total price of all items.
  double get precioTotal {
    double total = 0.0;
    _carritoCompras.productosPedido!.forEach((p) => total += p.precio!);
    return total;
  }

  int get totalProductos {
    return _carritoCompras.productosPedido!.length;
  }

  /// Adds [item] to cart.
  void add(CartItem item) {
    _carritoCompras.productosPedido!.add(item);
    notifyListeners();
  }

  void delete(int index) {
    _carritoCompras.productosPedido!.removeAt(index);
    notifyListeners();
  }

  /// Removes all items from the cart.
  void vaciarCarrito() {
    _carritoCompras.productosPedido!.clear();
    notifyListeners();
  }

  void limpiarPedido() {
    _carritoCompras = Pedido();
    notifyListeners();
  }
}