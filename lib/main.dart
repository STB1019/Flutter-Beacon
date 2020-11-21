import 'package:Beacon/beaconPage.dart';
import 'package:flutter/material.dart';

import 'orm/dbprovider.dart';
import 'orm/task.dart';

void main() => runApp(BeaconApp());

class BeaconApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lime, //boh
      title: 'B', //boh
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

//I need a stateful widget because screen is going to change if we find a new Beacon
class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _beaconName = <String>[];
  final _selectedBeacons = Set<String>();
  Color cardColor;

  String formVarText;
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  //This method is executed first
  @override
  void initState() {
    super.initState();
    formVarText = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        title: Text("Beacon BLE"),
        backgroundColor: Colors.purple,
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.sync),
                onPressed: () {
                  // SnackBar pops up a message for a certain interval of time
                  // ScaffoldMessenger handles SnackBars
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Avvio reset DB"),
                      duration: Duration(seconds: 1, milliseconds: 500)));
                  DBMS.internal().createDB().then((value) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("DB settato")));
                  });
                },
              );
            },
          ),
        ],
      ),

      ////////////////////////body: Container(
      ////////////////////////child: _buildBeaconFound(),
      ////////////////////////),

      body: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
                initialValue: formVarText,
                autovalidateMode: AutovalidateMode.always,
                decoration: InputDecoration(hintText: "Aggiungi promemoria"),
                maxLines: 5,
                minLines: 1,
                validator: (String val) {
                  if (val.trim().length == 0)
                    return "Attenzione, non è corretto inviare una stringa vuota";
                  formVarText = val.trim();
                  return null;
                },
                onSaved: (String param) => param.trim(),
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                }),
            Expanded(
                child: FutureBuilder(
                    future: TaskEntity.getAll(DBMS()),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Text("Non funziona niente\n${snapshot.error}");
                      if (snapshot.hasData) if (snapshot.data.length == 0)
                        return Text("Nessun dato");
                      else {
                        snapshot.data.forEach((value) {
                          print(value.runtimeType);
                          print(value);
                        });
                      }
                      return Container(
                          width: 200,
                          child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                TaskEntity task =
                                    snapshot.data[index] as TaskEntity;
                                return ListTile(
                                  title: Text(task.name),
                                  subtitle: Text(task.id),
                                );
                              }));
                      //TODO
                    }))
          ],
        ),
        onChanged: () {},
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () {
              setState(() {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Salvataggio in corso"),
                  duration: Duration(seconds: 2, milliseconds: 500),
                ));
                TaskEntity task = TaskEntity.fromMap({"name": formVarText});
                ModelEntity.insert(DBMS.internal(), task,
                    tableName: TaskEntity.tableName);
                formVarText = "";
              });
            },
            tooltip: 'Invio',
            child: Icon(
              Icons.add,
              color: Colors.green[300],
            ),
          );
        }, // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Widget _buildBeaconFound() {
    return ListView.builder(itemBuilder: (context, index) {
      // this is for an infinite list of cards
      //if (index >= _beaconName.length) {
      //  _beaconName.add(index.toString());
      //}
      _beaconName.add("Giulio");
      _beaconName.add("Giorgio");
      _beaconName.add("Marco");
      _beaconName.add("Paolo");

      return Card(child: _buildRow(_beaconName[index]));
    });
  }

  Widget _buildRow(String text) {
    final selected = _selectedBeacons.contains(text);
    return ListTile(
        leading: FlutterLogo(
          size: 40,
        ),
        title: Text("Beacon"),
        subtitle: Text("name: " + text.toString()),
        trailing: GestureDetector(
          onTap: () {
            setState(() {
              if (selected)
                _selectedBeacons.remove(text);
              else
                _selectedBeacons.add(text);
            });
          },
          child: Icon(
            selected ? Icons.wb_sunny : Icons.wb_sunny_outlined,
            color: selected ? Colors.amber : null,
          ),
        ),
        tileColor: cardColor,
        onTap: () {
          setState(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BeaconPage(text.toString())));
          });
        });
  }
}
