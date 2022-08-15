import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'cartmodel.dart';
import 'cartpage.dart';
import 'checkout.dart';
import 'home.dart';

void main() => runApp(Guppy());

class Guppy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<CartModel>(
      model: CartModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Guppy',
        home: HomePage(),
        routes: {
          '/home': (context) => HomePage(),
          '/cart': (context) => CartPage(),
          '/checkout': (context) => CheckoutPage(),
        },
        theme: _getThemeData(),
      ),
    );
  }

  ThemeData _getThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xff69fff1),
      fontFamily: 'Georgia',
      textTheme: const TextTheme(
        headline1: TextStyle(
          fontSize: 72.0,
          fontWeight: FontWeight.bold,
          color: Color(0xff63d471),
        ),
        headline6: TextStyle(
          fontSize: 36.0,
          fontStyle: FontStyle.italic,
          color: Color(0xff63a46C),
        ),
        bodyText2: TextStyle(
          fontSize: 14.0,
          fontFamily: 'Hind',
          color: Color(0xff6A7152),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Color(0xff63d471),
          textStyle: const TextStyle(
            color: Color(0xff69fff1),
            fontSize: 20,
            wordSpacing: 2,
            letterSpacing: 2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          primary: Color(0xff63d471),
          //backgroundColor: Colors.green,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Color(0xff63d471),
        )
      )
    );
  }
}
