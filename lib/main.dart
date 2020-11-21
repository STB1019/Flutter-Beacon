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
  final _beaconName = <String>["Giulio", "Giorgio", "Marco", "Paolo"];
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
      ),
      body: Container(
        child: _buildBeaconFound(),
      ),
    );
  }

  Widget _buildBeaconFound() {
    return ListView.builder(
        itemCount: _beaconName.length,
        itemBuilder: (context, index) {
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
