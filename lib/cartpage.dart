import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'cartmodel.dart';

class CartPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CartPageState();
  }
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito"),
        actions: <Widget>[
          TextButton(
              child: const Text(
                "Limpiar",
              ),
              onPressed: () => ScopedModel.of<CartModel>(context).clearCart())
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    CartModel model = ScopedModel.of<CartModel>(context, rebuildOnChange: true);
    bool cartHasItems = model.total > 0;
    if (cartHasItems) {
      return _buildCartDetail();
    }
    return _buildEmptyCartMessage();
  }

  Widget _buildEmptyCartMessage() {
    return const Center(
      child: Text("No hay productos en el carrito :'("),
    );
  }

  Widget _buildCartDetail() {
    CartModel cart = ScopedModel.of<CartModel>(context, rebuildOnChange: true);
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          _buildProductsDetail(cart),
          _buildTotal(cart.totalCartValue),
          _buildBuyNowButton(),
        ],
      ),
    );
  }

  Expanded _buildProductsDetail(CartModel cart) {
    return Expanded(
      child: ListView.builder(
        itemCount: cart.total,
        itemBuilder: (context, index) {
          return ScopedModelDescendant<CartModel>(
            builder: (context, child, model) {
              Product product = model.cart[index];
              return _buildProductDetail(
                product,
                onAdd: () => model.updateProduct(product, product.qty + 1),
                onRemove: () => model.updateProduct(product, product.qty - 1),
              );
            },
          );
        },
      ),
    );
  }

  ListTile _buildProductDetail(Product product, {onAdd, onRemove}) {
    double subTotal = product.qty * product.price;
    String itemDetail = "${product.qty} x ${product.price} = $subTotal";
    return ListTile(
      title: Text(product.title),
      subtitle: Text(itemDetail),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onAdd,
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: onRemove,
        ),
      ]),
    );
  }

  Container _buildTotal(double total) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Total: \$$total",
        style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  SizedBox _buildBuyNowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: const Text("Realizar Pedido"),
        onPressed: () => Navigator.pushNamed(context, '/checkout'),
      ),
    );
  }
}
