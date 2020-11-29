import 'package:Beacon/theme.dart';
import 'package:flutter/material.dart';

class BeaconDrawer extends StatefulWidget{
  @override
  _BeaconDrawerState createState() => _BeaconDrawerState();
}

class _BeaconDrawerState extends State<BeaconDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image:  AssetImage('assets/images/background1.jpg'))),
            child: Stack(children: <Widget>[
              Positioned(
                  bottom: 12.0,
                  left: 16.0,
                  child: Text("Flutter Step-by-Step",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500)
                  )
              ),
            ]
            )
          ),
          ListTile(
            title: Text(
              "Manage Regions",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {}
          ),
          ListTile(
            title: Text(
              "Dark Theme",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: Switch(
              value: ThemeBuilder.of(context).isDarkModeOn(),
              onChanged: (changedTheme){
                setState(() {
                  ThemeBuilder.of(context).changeTheme();
                });
              },
            ),
          ),
          ListTile(
            title: Text(
              "More Info",
              style: TextStyle(
                fontSize: 16,
              ),

            ),
            onTap: (){
              showAboutDialog(
                context: context,
                applicationVersion: '0.0.1',
                applicationIcon: Icon(Icons.agriculture),
                applicationLegalese: "bella raga",
                //roba
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String> createAlertDialog(BuildContext context){
    TextEditingController customController = TextEditingController();
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Add Region:"),
        content: TextField(
          controller: customController,
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text("Add"),
            onPressed: () {
              //customController is updated when the user inserts a text in the TextField,
              //this variable contains what the user has written.
              String toAdd = customController.text.toString();
              Navigator.of(context).pop(toAdd);
            },
          )
        ],
      );
    });
  }
}
