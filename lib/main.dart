import 'package:flutter/cupertino.dart';
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

  final _beaconCards = <Text>[];

  //This method is executed first
  @override
  void initState(){
    super.initState();
    //here I can fetch datas from Beacons
    print("This message is printed in initState() method");
  }


  Widget _buildRow(Text text) {
    return ListTile(
      title: Text(
        text.data,
      ),
    );
  }


  Widget _buildBeaconFound(){
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          if (index >= _beaconCards.length) {
            for(int j = 0; j < 1; j++){
              _beaconCards.add(Text("ciao " + index.toString()));
            }
          }
          return _buildRow(_beaconCards[index]);
        });
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Beacon BLE"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: _buildBeaconFound(),
        /*GridView.count(
        crossAxisCount: 2,
        children: <Widget>[Card(), Card(), Card(), Card(), Card()],
        //shows a grid viex with 2 columns of the widgets I will pass
      ),*/
      drawer: Drawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.whatshot_rounded),

      ),
    );
  }
}

