import 'package:Beacon/beaconPage.dart';
import 'package:flutter/material.dart';

void main() => runApp(BeaconApp());

class BeaconApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.amber,  //boh
      title: 'B',  //boh
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

//I need a stateful widget because screen is going to change if we find a new Beacon
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _beaconName = <String>[];
  final _selectedBeacons = Set<String>();
  Color cardColor;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Beacon BLE"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        child: _buildBeaconFound(),
      ),
      drawer: Drawer(),
    );
  }

  //This method is executed first
  @override
  void initState(){
    super.initState();
    //here I can fetch datas from Beacons
    cardColor = Colors.transparent;
    print("This message is printed in initState() method");
  }

  Widget _buildBeaconFound(){
    return ListView.builder(
        itemBuilder: (context, index) {
          if (index >= _beaconName.length) {
            _beaconName.add(index.toString());
          }
          return Card(
              child: _buildRow(_beaconName[index])
          );
        });
  }

  Widget _buildRow(String text) {
    final selected = _selectedBeacons.contains(text);
    return ListTile(
      leading: FlutterLogo(size: 40,),
      title: Text("Beacon"),
      subtitle: Text("name: " + text.toString()),
      trailing: GestureDetector(
        onTap: () {
          setState(() {
            if(selected) _selectedBeacons.remove(text);
            else _selectedBeacons.add(text);
          });
        },
        child: Icon(
          selected ? Icons.wb_sunny :Icons.wb_sunny_outlined,
          color: selected ? Colors.amber : null,
        ),
      ),
      tileColor: cardColor,
      onTap: () {
        setState(() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BeaconPage(text.toString())));
        });
      }
    );
  }

}

