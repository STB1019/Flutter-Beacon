import 'package:flutter/material.dart';

class BeaconPage extends StatelessWidget {

  final String _name;

  BeaconPage(this._name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
