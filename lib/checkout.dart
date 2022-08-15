import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:time_range_picker/time_range_picker.dart';

import 'cartmodel.dart';

var _visa_credit_card_number_regex = RegExp(r'^4\d{15}$');
var _visa_credit_card_cvv_regex = RegExp(r'^\d{3}$');
var _visa_credit_card_name_regex =
    RegExp(r'^([A-Za-z]+\s)([A-Za-z]+)\s{0,1}([A-Za-z]+){0,1}$');

var _visa_credit_card_expiration_date =
    RegExp(r"^(0[1-9]|1[0-2])\/?([0-9]{4}|[0-9]{2})$");

class CheckoutPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Realizar Pedido"),
      ),
      body: _CheckoutForm(),
    );
  }
}

class _CheckoutForm extends StatefulWidget {
  @override
  State<_CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<_CheckoutForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 40.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              OrderDetail(),
              AddressInformation(),
              PaymentMethod(),
              ShipmentMoment(),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            CartModel cart = ScopedModel.of<CartModel>(context);
            cart.clearCart();
            Navigator.of(context).pushNamedAndRemoveUntil(
                "/home", (Route<dynamic> route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido Enviado')),
            );
          }
        },
        child: const Text('Enviar Pedido'),
      ),
    );
  }
}

/*
Order Detail
*/
class OrderDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartModel cart = ScopedModel.of<CartModel>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          const Text("Detalle Del Pedido"),
          Column(
            children: [
              ListTile(
                title: const Text("Subtotal:"),
                trailing: Text("\$ ${cart.cartTotal().toStringAsFixed(2)}"),
              ),
              const ListTile(
                title: Text("Envio:"),
                trailing: Text("\$ 100.00"),
              ),
              ListTile(
                title: const Text("Total:"),
                trailing: Text(
                    "\$ ${cart.cartTotalWithShipping().toStringAsFixed(2)}"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*
Address
*/

class AddressInformation extends StatefulWidget {
  @override
  State<AddressInformation> createState() => _AddressInformationState();
}

class _AddressInformationState extends State<AddressInformation> {
  String dropdownValue = 'Córdoba';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          const Text("Domicilio"),
          _buildStreetNameTextField(context),
          Row(
            children: [
              Expanded(child: _buildDropdownButton()),
              Expanded(child: _buildStreetNumberTextField()),
            ],
          ),
        ],
      ),
    );
  }

  TextFormField _buildStreetNameTextField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Ingresá la calle',
      ),
      validator: (value) {
        if (value != null) {
          if (value.trim().isEmpty) {
            return "Ingrese un nombre no vacío.";
          }
        }
        return null;
      },
    );
  }

  TextFormField _buildStreetNumberTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Ingresá la altura',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value != null) {
          if (value.trim().isEmpty) {
            return "Ingrese una altura no vacía.";
          }

          int enteredValue = int.parse(value);

          if (enteredValue <= 0) {
            return "Ingrese una altura positiva.";
          }
        }
        return null;
      },
    );
  }

  DropdownButton<String> _buildDropdownButton() {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 0,
      //style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        //color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['Córdoba', 'Villa Allende', 'La Calera']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

/*
Payment
*/
enum PaymentMethods { cash, visa }

class PaymentMethod extends StatefulWidget {
  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  PaymentMethods? _paymentMethod = PaymentMethods.cash;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          const Text("Forma De Pago"),
          Row(
            children: [
              Expanded(child: _buildCashOption()),
              Expanded(child: _buildVISAOption())
            ],
          ),
          _buildPaymentInput(),
        ],
      ),
    );
  }

  ListTile _buildVISAOption() {
    return ListTile(
      title: const Text('Tarjeta VISA'),
      leading: Radio<PaymentMethods>(
        value: PaymentMethods.visa,
        groupValue: _paymentMethod,
        onChanged: (PaymentMethods? value) {
          setState(() {
            _paymentMethod = value;
          });
        },
      ),
    );
  }

  ListTile _buildCashOption() {
    return ListTile(
      title: const Text('Efectivo'),
      leading: Radio<PaymentMethods>(
        value: PaymentMethods.cash,
        groupValue: _paymentMethod,
        onChanged: (PaymentMethods? value) {
          setState(() {
            _paymentMethod = value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentInput() {
    if (_paymentMethod == PaymentMethods.cash) {
      return _buildCashInput();
    }
    return _buildVISAInput();
  }

  Widget _buildVISAInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          _cardNumber(),
          _cardName(),
          Row(
            children: [
              Expanded(
                child: _cardDate(),
                flex: 3,
              ),
              Expanded(
                child: _cardCVV(),
                flex: 1,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardNumber() {
    var cardMask = MaskTextInputFormatter(
      mask: '#### - #### - #### - ####',
      filter: {"#": RegExp(r'[0-9]')},
    );
    return TextFormField(
      inputFormatters: [cardMask],
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Numero de La tarjeta',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null) {
          if (value.isEmpty) {
            return "Ingrese un número de tarjeta no vacío.";
          }
          var cardNumber = value.replaceAll("-", "").replaceAll(" ", "");
          if (!_visa_credit_card_number_regex.hasMatch(cardNumber)) {
            return "Ingrese un número de tarjeta VISA válido.";
          }
        }
        return null;
      },
    );
  }

  Widget _cardName() {
    return TextFormField(
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Titular de la tarjeta',
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value != null) {
          if (value.isEmpty) {
            return "Ingrese Nombre no vacío.";
          }
          if (!_visa_credit_card_name_regex.hasMatch(value)) {
            return "Ingrese un Nombre válido.";
          }
        }
        return null;
      },
    );
  }

  Widget _cardDate() {
    var expirationMask = MaskTextInputFormatter(
      mask: '##/##',
      filter: {"#": RegExp(r'[0-9]')},
    );
    return TextFormField(
      inputFormatters: [expirationMask],
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Fecha Vencimiento',
      ),
      keyboardType: TextInputType.datetime,
      validator: (value) {
        if (value != null) {
          if (value.isEmpty) {
            return "Ingrese Vencimiento no vacío.";
          }

          if (!_visa_credit_card_expiration_date.hasMatch(value)) {
            return "Ingrese una fecha válida";
          }

          var month = int.parse(value.split("/")[0]);
          var year = int.parse(value.split("/")[1]) + 2000;
          var now = DateTime.now();
          if (now.year > year || now.year == year && now.month >= month) {
            return "Ingrese una fecha válida.";
          }
        }
        return null;
      },
    );
  }

  Widget _cardCVV() {
    var cvvMask = MaskTextInputFormatter(
      mask: '###',
      filter: {"#": RegExp(r'[0-9]')},
    );
    return TextFormField(
      inputFormatters: [cvvMask],
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'CVV',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null) {
          if (value.isEmpty) {
            return "Ingrese CVV no vacío.";
          }
          if (!_visa_credit_card_cvv_regex.hasMatch(value)) {
            return "Ingrese CVV válido.";
          }
        }
        return null;
      },
    );
  }

  Widget _buildCashInput() {
    return TextFormField(
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Ingresá con cuanto pagas',
      ),
      inputFormatters: [CurrencyTextInputFormatter(symbol: "\$")],
      keyboardType: TextInputType.number,
      validator: (value) {
        CartModel cart = ScopedModel.of<CartModel>(context);
        if (value != null) {
          if (value.isEmpty) {
            return "Ingrese un monto no vacío.";
          }

          String cleanedValue = value.replaceAll("\$", "").replaceAll(",", "");
          double enteredValue = double.parse(cleanedValue);

          if (enteredValue <= 0) {
            return "Ingrese un monto positivo mayor a 0.";
          }
          if (enteredValue < cart.cartTotalWithShipping()) {
            return "El monto debe ser igual o mayor al total.";
          }
        }
        return null;
      },
    );
  }
}

/*
Shipment
*/

enum ShipmentMoments { asap, selected }

class ShipmentMoment extends StatefulWidget {
  @override
  State<ShipmentMoment> createState() => _ShipmentMomentState();
}

class _ShipmentMomentState extends State<ShipmentMoment> {
  ShipmentMoments? _shipmentMoments = ShipmentMoments.asap;
  final _dateFormat = DateFormat("dd/MM/yyyy");
  late DateTime _selectedDate;
  late TimeRange _selectedRange;
  final TimeRange _initialTimeRange = TimeRange(
      startTime: TimeOfDay.now(),
      endTime: TimeOfDay.now().replacing(
        hour: TimeOfDay.now().hour + 1,
      ));

  @override
  void initState() {
    _selectedDate = DateTime.now();
    _selectedRange = _initialTimeRange;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          const Text("Envío"),
          Row(
            children: [
              Expanded(child: _buildASAPOption()),
              Expanded(child: _buildSelectedOption())
            ],
          ),
          _buildShipmentInput(),
        ],
      ),
    );
  }

  ListTile _buildASAPOption() {
    return ListTile(
      title: const Text('Lo Antes Posible'),
      leading: Radio<ShipmentMoments>(
        value: ShipmentMoments.asap,
        groupValue: _shipmentMoments,
        onChanged: (ShipmentMoments? value) {
          setState(() {
            _shipmentMoments = value;
          });
        },
      ),
    );
  }

  ListTile _buildSelectedOption() {
    return ListTile(
      title: const Text('Elegir Fecha'),
      leading: Radio<ShipmentMoments>(
        value: ShipmentMoments.selected,
        groupValue: _shipmentMoments,
        onChanged: (ShipmentMoments? value) {
          setState(() {
            _shipmentMoments = value;
          });
        },
      ),
    );
  }

  Widget _buildShipmentInput() {
    if (_shipmentMoments == ShipmentMoments.selected) {
      return _buildSelectedDate();
    }
    return Container();
  }

  Widget _buildSelectedDate() {
    return Column(
      children: <Widget>[
        // const Text('Ingresá la fecha'),
        _buildDateInput(),
        _buildHourRangeInput(),
      ],
    );
  }

  Widget _buildDateInput() {
    String formattedDate = _dateFormat.format(_selectedDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
          child: Text("Fecha de Entrega"),
        ),
        Expanded(
          child: Text(formattedDate),
        ),
        Expanded(
          child: TextButton(
              child: const Text("Cambiar Fecha"),
              onPressed: () async {
                var date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  initialDate: _selectedDate,
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                );
                setState(() {
                  _selectedDate = date ?? DateTime.now();
                });
              }),
        )
      ],
    );
  }

  Widget _buildHourRangeInput() {
    var formattedRange = "${_selectedRange.startTime.format(context)} "
        "y ${_selectedRange.endTime.format(context)}";

    TimeRange? disabledTime;

    if (isToday(_selectedDate)) {
      disabledTime = TimeRange(
          startTime: TimeOfDay.now().replacing(hour: 3, minute: 0),
          endTime: TimeOfDay.now());
    } else {
      disabledTime = null;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(
          child: Text("Hora de Entrega"),
        ),
        Expanded(
          child: Text(formattedRange),
        ),
        Expanded(
          child: TextButton(
              child: const Text("Cambiar Rango"),
              onPressed: () async {
                TimeRange range = await showTimeRangePicker(
                  context: context,
                  disabledTime: disabledTime,
                  labels: _getLabels(),
                );
                setState(() {
                  _selectedRange = range;
                });
              }),
        )
      ],
    );
  }

  List<ClockLabel> _getLabels() {
    var labels = [
      "12 am",
      "3 am",
      "6 am",
      "9 am",
      "12 pm",
      "3 pm",
      "6 pm",
      "9 pm"
    ];
    return labels.asMap().entries.map((e) {
      return ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value);
    }).toList();
  }

  bool isToday(DateTime dateTime) {
    DateTime now = DateTime.now();

    DateTime nowToCompare = DateTime(now.year, now.month, now.day);
    DateTime dateTimeToCompare = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    return dateTimeToCompare.difference(nowToCompare).inDays == 0;
  }
}
