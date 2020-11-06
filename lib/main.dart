import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon BLE',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

//I need a stateful widget beacuse screen is going to change if we find a new Beacon
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //This method is executed first
  @override
  void initState(){
    super.initState();
    //here I can fetch datas from Beacons
    print("This message is printed in initState() method");
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Beacon BLE"),
        backgroundColor: Colors.amber,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[Card(), Card(), Card(), Card(), Card()],
      ), //shows a grid viex with 2 columns of the widgets I will pass
      drawer: Drawer(),
    );
  }
}