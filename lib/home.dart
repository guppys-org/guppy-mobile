import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'cartmodel.dart';

final List<Product> _products = [
  Product(
    id: 1,
    title: "Pizza",
    price: 1500.0,
    imgUrl: "https://img.icons8.com/plasticine/2x/pizza.png",
    qty: 1,
  ),
  Product(
    id: 2,
    title: "Banana",
    price: 40.0,
    imgUrl: "https://img.icons8.com/cotton/2x/banana.png",
    qty: 1,
  ),
  Product(
    id: 3,
    title: "Naranja",
    price: 20.0,
    imgUrl: "https://img.icons8.com/cotton/2x/orange.png",
    qty: 1,
  ),
  Product(
    id: 4,
    title: "Sandía",
    price: 40.0,
    imgUrl: "https://img.icons8.com/cotton/2x/watermelon.png",
    qty: 1,
  ),
  Product(
    id: 5,
    title: "Palta",
    price: 25.0,
    imgUrl: "https://img.icons8.com/cotton/2x/avocado.png",
    qty: 1,
  ),
];

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Home"),
      actions: <Widget>[
        ScopedModelDescendant<CartModel>(
          builder: (context, child, model) {
            bool enabled = model.total > 0;
            return IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed:
                  enabled ? () => Navigator.pushNamed(context, '/cart') : null,
            );
          },
        )
      ],
    );
  }

  GridView buildBody() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return ScopedModelDescendant<CartModel>(
          builder: (context, child, model) {
            Product product = _products[index];
            return _buildProductCard(
              product,
              onAdd: () => model.addProduct(product),
            );
          },
        );
      },
    );
  }

  Card _buildProductCard(Product product, {onAdd}) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(
            product.imgUrl,
            height: 120,
            width: 120,
          ),
          Text(
            product.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text("\$${product.price}"),
          OutlinedButton(
            child: const Text("Agregar"),
            onPressed: onAdd,
          )
        ],
      ),
    );
  }
}
