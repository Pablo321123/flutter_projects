import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Calculadora_Home());
  }
}

class Calculadora_Home extends StatefulWidget {
  const Calculadora_Home({Key? key}) : super(key: key);

  @override
  _Calculadora_HomeState createState() => _Calculadora_HomeState();
}

class _Calculadora_HomeState extends State<Calculadora_Home> {
  double? _imc;
  String texto = "";
  TextEditingController txtPesoController = TextEditingController();
  TextEditingController txtAlturaController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _resetFields() {
    setState(() {
      txtPesoController.text = "";
      txtAlturaController.text = "";
      _imc = null;
      _formKey = GlobalKey<FormState>();
    });
  }

  void _calcularImc() {
    setState(() {
      double peso = double.parse(txtPesoController.text);
      double altura = double.parse(txtAlturaController.text) / 100;
      String valor = "";

      _imc = peso / (altura * altura);
      valor = _imc!.toStringAsPrecision(3);
      if (_imc! < 18.6) {
        texto = "Você está abaixo do peso ideal!\nSeu IMC é de: $valor";
      } else if (_imc! < 24.9) {
        texto = "Peso Ideal!\nSeu IMC é de: $valor";
      } else if (_imc! < 29.9) {
        texto = "Levemente acima do Peso!\nSeu IMC é de: $valor";
      } else if (_imc! < 34.9) {
        texto = "Obesidade Grau I!\nSeu IMC é de: $valor";
      } else if (_imc! < 39.9) {
        texto = "Obesidade Grau II!\nSeu IMC é de: $valor";
      } else {
        texto = "Obesidade Grau III!\nSeu IMC é de: $valor";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de IMC"),
        elevation: 1.0,
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        actions: <Widget>[
          IconButton(onPressed: _resetFields, icon: const Icon(Icons.refresh))
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            //Eixo cruzado, no caso da coluna é a horizontal
            children: <Widget>[
              const Icon(Icons.person_outline,
                  size: 120.0, color: Colors.deepOrange),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Peso (kg)",
                    labelStyle: TextStyle(color: Colors.deepOrange)),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.deepOrange, fontSize: 20),
                controller: txtPesoController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Insira o seu peso!";
                  } else {
                    _calcularImc();
                  }
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: "Altura (cm)",
                    labelStyle: TextStyle(color: Colors.deepOrange)),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.deepOrange, fontSize: 20),
                controller: txtAlturaController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Insira a sua altura!";
                  } else {
                    _calcularImc();
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Text(
                  _imc == null ? "Informe seus dados!" : texto,
                  style: const TextStyle(
                      color: Colors.deepOrange, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _calcularImc;
          }
        },
        child: Icon(Icons.calculate),
        elevation: 4.0,
        backgroundColor: Colors.deepOrange,
        tooltip: "Calcular",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.deepOrange,
        elevation: 1.0,
        child: Container(
          height: 50.0,
        ),
      ),
    );
  }
}
