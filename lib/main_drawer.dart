import 'package:Beacon/manage_regions_page.dart';
import 'package:Beacon/theme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_beacon/flutter_beacon.dart';

class BeaconDrawer extends StatefulWidget{
  final List<Region> savedRegions;
  BeaconDrawer(this.savedRegions);
  @override
  _BeaconDrawerState createState() => _BeaconDrawerState(savedRegions);
}

class _BeaconDrawerState extends State<BeaconDrawer> {
  final List<Region> savedRegions;
  _BeaconDrawerState(this.savedRegions);

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
            onTap: () {
              setState(() {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ManageRegionsPage(savedRegions)));
              });
            }
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
}
