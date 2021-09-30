import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart'; //Biblioteca que nos permite fazer um requisição assincrona, ou seja, o app contianua funcionando enquanto espera um determinado evento acontecer

const request = "https://api.hgbrasil.com/finance?key=399e4ada";

void main() async {
  print(await getData());
  runApp(MyApp());
}

Future<Map> getData() async {
  http.Response? response = await http.get(request);
  var arquivoJason = json.decode(response.body)["results"]
      ["currencies"]; //Convert o Jason em um Map

  return arquivoJason;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Conversor de Moedas",
      home: const HomeContent(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green)),
              hintStyle: TextStyle(color: Colors.amber))),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  double dolar = 0.0;
  double euro = 0.0;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final realController = TextEditingController();

  void resertFields() {
    _formKey = GlobalKey<FormState>();
  }

  void _realChanged(String text) {
    double real = text.isEmpty ? 0.0 : double.parse(text);

    controllers[1].text = (real / dolar).toStringAsFixed(2);
    controllers[2].text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = text.isEmpty ? 0.0 : double.parse(text);
    controllers[0].text = (dolar * this.dolar).toStringAsFixed(2);
    controllers[2].text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = text.isEmpty ? 0.0 : double.parse(text);
    controllers[0].text = (euro * this.euro).toStringAsFixed(2);
    controllers[1].text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  var controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  double teste = 0.0;

  Widget _buildLoading(String texto) {
    return Center(
        child: Text(
      texto,
      style: TextStyle(color: Colors.amber),
    ));
  }

  Widget _buildTextField(
      {required String tipoMoeda,
      required tipoMoedaAbreviado,
      Color? color,
      required TextEditingController controlador,
      Function(String texto)? f}) {
    Function(String texto)? funcao = f ?? (texto) {};

    return TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: tipoMoeda,
            labelStyle: TextStyle(color: color ?? Colors.amber),
            border: const OutlineInputBorder(),
            prefixText: tipoMoedaAbreviado),
        style: const TextStyle(color: Colors.amber, fontSize: 20.0),
        controller: controlador,
        onChanged: funcao,
        onTap: () {
          controlador.text = "";
        },
        validator: (value) {
          if (value!.isEmpty) {
            return "Informe o(s) $tipoMoeda";
          } else {
            funcao;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "\$ Conversor \$",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none: //Parado
            case ConnectionState.waiting: //Esperando
              return _buildLoading("Carregando dados...");
              break;
            default:
              if (snapshot.hasError) {
                return const Center(
                    child: Text(
                  "Erro ao Carregar dados!",
                  style: TextStyle(color: Colors.red),
                ));
              } else {
                dolar = snapshot.data!["USD"]["buy"];
                euro = snapshot.data!["EUR"]["buy"];

                return SingleChildScrollView(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Icon(
                            Icons.monetization_on,
                            size: 150,
                            color: Colors.green,
                          ),
                          _buildTextField(
                            tipoMoeda: "Reais",
                            tipoMoedaAbreviado: "R\$",
                            controlador: controllers[0],
                            f: _realChanged,
                          ),
                          const Divider(),
                          _buildTextField(
                            tipoMoeda: "Dólares",
                            tipoMoedaAbreviado: "U\$",
                            controlador: controllers[1],
                            f: _dolarChanged,
                          ),
                          const Divider(),
                          _buildTextField(
                            tipoMoeda: "Euros",
                            tipoMoedaAbreviado: "€\$",
                            controlador: controllers[2],
                            f: _euroChanged,
                          ),
                          const Divider(),
                        ],
                      ),
                    ));
              }
              break;
          }
        },
      ),
    );
  }
}
