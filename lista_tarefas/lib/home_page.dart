import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lista_tarefas/utils.dart';
import 'package:path_provider/path_provider.dart';

class ListaTarefas extends StatelessWidget {
  const ListaTarefas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Lista de Tarefas",
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  Map<String, dynamic> _lastRemovedItem = Map();
  int _lastRemovedItemPosition = -1;
  FloatingActionButton? btVoador = null;

  @override
  void initState() {
    //Chamado toda vez que inicializamos o estado da nossa tela ()
    super.initState();

    readData().then((data) {
      setState(() {
        _toDoList = lerJson(data!);
      });
    }); //Sempre que o readData retornar um dado no futuro, ele chamara uma funcao
  }

  Widget _itemListBuilder(BuildContext context, int index) {
    {
      return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        //String que monitora qual item que está sendo deslizado
        background: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment(-0.8, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
        child: CheckboxListTile(
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(
              _toDoList[index]["ok"] ? Icons.check : Icons.error,
            ),
          ),
          onChanged: (valueChanged) {
            setState(() {
              _toDoList[index]["ok"] = valueChanged;
              saveData(_toDoList);
            });
          },
        ),
        onDismissed: (diretion) {
          setState(() {
            _lastRemovedItem = _toDoList[index];
            _lastRemovedItemPosition = index;
            _toDoList.remove(_toDoList[index]);
            saveData(_toDoList);

            final snack = SnackBar(
              content: Text("Tarefa ${_lastRemovedItem["title"]} removida!"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(index, _lastRemovedItem);
                    saveData(_toDoList);
                  });
                },
              ),
              duration: Duration(seconds: 3),
            );
            //Scaffold.of(context).showSnackBar(snack);
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snack);
          });
        },
      );
    }
  }

  final txtListaController = TextEditingController();

  void _addToDo() {
    setState(() {
      Map<String, dynamic> _mapTasks = Map();
      _mapTasks["title"] = txtListaController.text;
      _mapTasks["ok"] = false;
      txtListaController.text = "";

      _toDoList.add(_mapTasks);
      saveData(_toDoList);
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(
        Duration(seconds: 1)); //Fica o tempo de 1 segundo esperando

    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });

      saveData(_toDoList);
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Lista de tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: txtListaController,
                    decoration: const InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  )),
                ],
              ),
            ),
            Expanded(
                child: RefreshIndicator(
                    child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20),
                        itemCount: _toDoList.length,
                        itemBuilder: _itemListBuilder),
                    onRefresh: _refresh))
          ],
        ),
        floatingActionButton: txtListaController.text.isEmpty
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.add),
                backgroundColor: Colors.blueAccent,
                onPressed: _addToDo),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.blueAccent,
          child: Container(
            height: 50.0,
          ),
        ));
  }
}
