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
        backgroundColor: Colors.indigo,
      ),
      body: Text("Proximity UUID:\n" +
          beacon.proximityUUID +
          "\n\n" +
          "Transmission Power: \n" +
          beacon.txPower.toString() + " dBm" +
          "\n\n" +
          "Received Signal Strenght Indication: \n" +
          beacon.rssi.toString() + " dBm" +
          "\n\n" +
          "distance: \n" +
          beacon.accuracy.toString() + " m"),
    );
  }
}
