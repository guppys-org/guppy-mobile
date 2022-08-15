import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  List<Product> cart = [];
  double totalCartValue = 0;

  int get total => cart.length;


  void addProduct(product) {
    int index = cart.indexWhere((i) => i.id == product.id);
    if (index != -1) {
      updateProduct(product, product.qty + 1);
    } else {
      cart.add(product);
      calculateTotal();
      notifyListeners();
    }
  }

  void removeProduct(product) {
    int index = cart.indexWhere((i) => i.id == product.id);
    cart[index].qty = 1;
    cart.removeWhere((item) => item.id == product.id);
    calculateTotal();
    notifyListeners();
  }

  void updateProduct(product, qty) {
    int index = cart.indexWhere((i) => i.id == product.id);
    cart[index].qty = qty;
    if (cart[index].qty == 0) removeProduct(product);

    calculateTotal();
    notifyListeners();
  }

  void clearCart() {
    cart.forEach((f) => f.qty = 1);
    cart = [];
    notifyListeners();
  }

  void calculateTotal() {
    totalCartValue = 0;
    cart.forEach((f) {
      totalCartValue += f.price * f.qty;
    });
  }

  double cartTotal() {
    double total = 0;
    for (var f in cart) {
      total += f.price * f.qty;
    }
    return total;
  }

  double cartTotalWithShipping() {
    double subtotal = 0;
    for (var f in cart) {
      subtotal += f.price * f.qty;
    }
    return subtotal + 100;
  }
}

class Product {
  int id;
  String title;
  String imgUrl;
  double price;
  int qty;

  Product(
      {required this.id,
      required this.title,
      required this.price,
      required this.qty,
      required this.imgUrl});
}
