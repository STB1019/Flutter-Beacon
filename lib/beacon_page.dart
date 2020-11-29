import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

class BeaconPage extends StatelessWidget {
  final Beacon beacon;

  BeaconPage(this.beacon);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(beacon.macAddress),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        child: Text(
                          "Sconosciuto",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        child: GestureDetector(
                          child: Icon(Icons.star_border),
                          onTap: () {},
                        ),
                      )
                    ],
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text("Proximity UUID: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text(beacon.proximityUUID),
                    trailing: GestureDetector(
                      child: Icon(Icons.menu),
                      onTap: () {},
                    ),
                  ),
                ),
                Card(
                  child: Column(
                      children: [
                        ListTile(
                          title: Text("Major:",
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          subtitle: Text(beacon.major.toString()),
                        ),
                        ListTile(
                          title: Text("Minor:",
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          subtitle: Text(beacon.minor.toString()),
                        ),
                        ListTile(
                          title: Text("Distance:",
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          subtitle: Text(beacon.accuracy.toString() + " m"),
                        ),
                        ListTile(
                          title: Text("Transmission Power:",
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          subtitle: Text(beacon.txPower.toString() + " dBm"),
                        ),
                        ListTile(
                          title: Text("Received Signal Strenght Indication:",
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          subtitle: Text(beacon.rssi.toString() + " dBm"),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ));
  }
}
