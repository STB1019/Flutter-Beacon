import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(BeaconApp());

class BeaconApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.amber,
      title: 'Beacon BLE',
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
  Color cardColor;

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
    return ListTile(
      leading: FlutterLogo(size: 40,),
      title: Text("Beacon"),
      subtitle: Text("name: " + text.toString()),
      trailing: const Icon(Icons.more_horiz),
      tileColor: cardColor,
      onTap: () {
        setState(() {
          if(cardColor == Colors.amberAccent) cardColor = Colors.transparent;
          else cardColor = Colors.amberAccent;
        });
      }
    );
  }


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
        /*GridView.count(
        crossAxisCount: 2,
        children: <Widget>[Card(), Card(), Card(), Card(), Card()],
        //shows a grid viex with 2 columns of the widgets I will pass
      ),*/
      drawer: Drawer(),
    );
  }
}

