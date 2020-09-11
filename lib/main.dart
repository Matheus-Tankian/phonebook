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

  final _nameControler = TextEditingController();
  final _numberController = TextEditingController();

  List _listContats = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  String _addFavorite = "adicionado aos";
  String _removideFavorite = "removido dos";

  @override
  void initState(){
    super.initState();

    _readData().then((data) {
      setState(() {
        _listContats = json.decode(data);
      });
    });
  }

  void _addContats() {

    setState(() {
      Map<String, dynamic> newList = Map();

      newList['name'] = _nameControler.text;
      _nameControler.text = '';

      newList['number'] = _numberController.text;
      _numberController.text = '';

      newList['favorite'] = false;

      _listContats.add(newList);
      _saveData();

    });

  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));


    setState(() {
      _listContats.sort((a , b) {
        if(a['favorite'] && !b['favorite'])
          return -1;
        else if (!a['favorite'] && b['favorite'])
          return 1;
        else
          return 0;
      });

      _saveData();
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
                  controller: _nameControler,
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
                        controller: _numberController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.blue[900]),
                        decoration: InputDecoration(
                            labelText:"Numero",
                            labelStyle: TextStyle(color: Colors.deepPurple[900])
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: _addContats,
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
                    itemCount: _listContats.length,
                    itemBuilder: buildItem,
                  ),
                  onRefresh: _refresh,
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
                  _listContats[index]['name'],
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                subtitle: Text(_listContats[index]['number']),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment(1.5, 0.0),
                child: IconButton(
                  color: Colors.deepPurpleAccent,
                  icon: Icon( _listContats[index]['favorite'] ? Icons.favorite: Icons.favorite_border),
                  tooltip: "Favotitar",
                  onPressed: () {
                    setState(() {
                      _listContats[index]['favorite'] = !_listContats[index]['favorite'];
                      _saveData();

                    });

                    final snack = SnackBar(
                      content:
                      Text(
                          "${_listContats[index]['name']} ${_listContats[index]['favorite'] ? _addFavorite : _removideFavorite} favoritos"),
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
                    content: Text("Ligando para ${_listContats[index]['name']} ..."),
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
          _lastRemoved = Map.from(_listContats[index]);
          _lastRemovedPos = index;
          _listContats.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Contato ${_lastRemoved['name']} deletado"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){
                  setState(() {
                    _listContats.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
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
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/contats.json");
  }

  // Salvar Dados
  Future<File> _saveData() async {
    String data = json.encode(_listContats);

    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();

    }catch (erro) {
      return null;
    }
  }
}

