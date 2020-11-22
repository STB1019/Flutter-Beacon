import 'package:flutter/material.dart';

import 'package:flutter_beacon/flutter_beacon.dart';

class BeaconPage extends StatelessWidget {

  final Beacon beacon;

  BeaconPage(this.beacon);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(beacon.proximityUUID),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

