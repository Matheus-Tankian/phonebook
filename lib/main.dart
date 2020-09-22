import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MaterialApp (
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final nameControler = TextEditingController();
  final numberController = TextEditingController();

  List listContats = [];

  Map<String, dynamic> _lastRemoved;
  int lastRemovedPos;

  String addFavorite = "adicionado aos";
  String removideFavorite = "removido dos";

  @override
  void initState(){
    super.initState();

    readData().then((data) {
      setState(() {
        listContats = json.decode(data);
      });
    });
  }

  void addContats() {

    setState(() {
      Map<String, dynamic> newList = Map();

      newList['name'] = _nameControler.text;
      nameControler.text = '';

      newList['number'] = _numberController.text;
      numberController.text = '';

      newList['favorite'] = false;

      listContats.add(newList);
      saveData();

    });

  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));


    setState(() {
      listContats.sort((a , b) {
        if(a['favorite'] && !b['favorite'])
          return -1;
        else if (!a['favorite'] && b['favorite'])
          return 1;
        else
          return 0;
      });

      saveData();
    });

    return null;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Agenda de Contatos"),
          backgroundColor: Colors.purple[900],
        ),
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(17, 1, 17, 1),
              child:
              Expanded(
                child: TextField(
                  controller: nameControler,
                  style: TextStyle(color: Colors.blue[900]),
                  decoration: InputDecoration(
                      labelText:"Nome",
                      labelStyle: TextStyle(color: Colors.deepPurple[900])
                  ),
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(17, 1, 17, 3),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: numberController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.blue[900]),
                        decoration: InputDecoration(
                            labelText:"Numero",
                            labelStyle: TextStyle(color: Colors.deepPurple[900])
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: addContats,
                      textColor: Colors.white,
                      color: Colors.deepPurpleAccent,
                      elevation: 10.0,
                      child:Text("Salvar"),
                    ),
                  ],
                )
            ),

            Expanded(
                child: RefreshIndicator(
                  child: ListView.builder(
                    itemCount: listContats.length,
                    itemBuilder: buildItem,
                  ),
                  onRefresh: refresh,
                )
            )
          ],
        )
    );
  }

  Widget buildItem(BuildContext context, int index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: Row(
          children: <Widget>[
            Expanded(
              child:ListTile(
                title: Text(
                  listContats[index]['name'],
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                subtitle: Text(listContats[index]['number']),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment(1.5, 0.0),
                child: IconButton(
                  color: Colors.deepPurpleAccent,
                  icon: Icon( listContats[index]['favorite'] ? Icons.favorite: Icons.favorite_border),
                  tooltip: "Favotitar",
                  onPressed: () {
                    setState(() {
                      listContats[index]['favorite'] = !listContats[index]['favorite'];
                      saveData();

                    });

                    final snack = SnackBar(
                      content:
                      Text(
                          "${listContats[index]['name']} ${listContats[index]['favorite'] ? addFavorite : removideFavorite} favoritos"),
                      duration: Duration(seconds: 2),
                    );

                    Scaffold.of(context).removeCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(snack);
                  },
                ),
              ),
            ),

            Expanded(
              child: IconButton(
                color: Colors.teal,
                icon: Icon(Icons.call),
                tooltip: "Fazer Ligacao",
                onPressed: (){
                  final snack = SnackBar(
                    content: Text("Ligando para ${listContats[index]['name']} ..."),
                    duration: Duration(seconds: 2),
                  );

                  Scaffold.of(context).removeCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(snack);
                },
              ),
            ),
          ]
      ),

      onDismissed: (direction) {
        setState(() {
          lastRemoved = Map.from(listContats[index]);
          lastRemovedPos = index;
          listContats.removeAt(index);

          saveData();

          final snack = SnackBar(
            content: Text("Contato ${lastRemoved['name']} deletado"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){
                  setState(() {
                    listContats.insert(lastRemovedPos, lastRemoved);
                    saveData();
                  });
                }),
            duration: Duration(seconds: 2),
          );

          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);

        });
      },
    );
  }

  // Recuperar arquivo do diretorio
  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/contats.json");
  }

  // Salvar Dados
  Future<File> saveData() async {
    String data = json.encode(listContats);

    final file = await getFile();

    return file.writeAsString(data);
  }

  Future<String> readData() async {
    try {
      final file = await getFile();

      return file.readAsString();

    }catch (erro) {
      return null;
    }
  }
}

