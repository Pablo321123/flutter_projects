import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

Future<File> getFile() async {
  final directory =
      await getApplicationDocumentsDirectory(); //Metodo no qual retorna o diretorio disponivel para gravação de dados
  return File("${directory.path}/data.json");
}

Future<File> saveData(List list) async {
  //Tudo que envolve carregamento e salvamento de dados não acontece instantaneamente
  String data = json.encode(list);

  final file = await getFile();

  return file.writeAsString(data);
}

Future<String?> readData() async {
  try {
    final file = await getFile();
    return file.readAsString();
  } catch (e) {
    return null;
  }
}

dynamic lerJson(String data) {
  return json.decode(data);
}
