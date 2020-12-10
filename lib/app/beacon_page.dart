import 'package:flutter/material.dart';
import 'package:Beacon/flutter_beacon/flutter_beacon.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class BeaconPage extends StatefulWidget {
  final Beacon beacon;
  final Region beaconRegion;

  BeaconPage(this.beacon, this.beaconRegion);

  @override
  _BeaconPageState createState() => _BeaconPageState(beacon, beaconRegion);
}

class _BeaconPageState extends State<BeaconPage> {
  final Beacon beacon;
  final Region beaconRegion;

  final _savedBeacons = <Beacon>[];
  String savedBeaconsFileName = "saved_beacons.json";
  File jsonFile;
  Directory dir;
  bool savedBeaconsFileExists = false;
  bool isFavorite = false;

  _BeaconPageState(this.beacon, this.beaconRegion);

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + savedBeaconsFileName);
      savedBeaconsFileExists = jsonFile.existsSync();
      if (savedBeaconsFileExists) {
        _updateBeaconsList()
            .then((value) => {if (beaconIsSaved()) isFavorite = true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.beacon.macAddress),
        ),
        body: FutureBuilder(
            future: _updateBeaconsList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return showBeaconInfoPage();
              } else
                return CircularProgressIndicator();
            }));
  }

  Widget showBeaconInfoPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.beaconRegion.identifier,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      child: Icon(isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite
                              ? Theme.of(context).accentColor
                              : IconTheme.of(context).color),
                      onTap: () {
                        if (!isFavorite) {
                          setState(() {
                            _addBeaconToJsonFile(beacon);
                            isFavorite = true;
                          });
                        } else {
                          setState(() {
                            _removeBeaconFromJsonFile(beacon);
                            isFavorite = false;
                          });
                        }
                      },
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
                subtitle: Text(widget.beacon.proximityUUID),
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
                    subtitle: Text(widget.beacon.major.toString()),
                  ),
                  ListTile(
                    title: Text("Minor:",
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    subtitle: Text(widget.beacon.minor.toString()),
                  ),
                  ListTile(
                    title: Text("Distance:",
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    subtitle: Text(widget.beacon.accuracy.toString() + " m"),
                  ),
                  ListTile(
                    title: Text("Transmission Power:",
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    subtitle: Text(widget.beacon.txPower.toString() + " dBm"),
                  ),
                  ListTile(
                    title: Text("Received Signal Strenght Indication:",
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    subtitle: Text(widget.beacon.rssi.toString() + " dBm"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void createBeaconsFile(
      List<Map<String, dynamic>> content, Directory dir, String fileName) {
    print("Creating file!");
    jsonFile = new File(dir.path + "/" + fileName);
    jsonFile.createSync();
    setState(() {
      savedBeaconsFileExists = true;
    });
    jsonFile.writeAsStringSync(json.encode(content));
  }

  void _addBeaconToJsonFile(Beacon beacon) {
    print("Writing to file!");
    Map<String, dynamic> toAdd = {
      'proximityUUID': beacon.proximityUUID,
      'major': beacon.major,
      'minor': beacon.minor,
      'macAddress': beacon.macAddress,
      'rssi': beacon.rssi,
      'txPower': beacon.txPower,
      'accuracy': beacon.accuracy
    };

    if (savedBeaconsFileExists) {
      print("File exists");
      var jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.add(toAdd);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    }
    if (!savedBeaconsFileExists) {
      print("File doesn't exist");
      List<Map<String, dynamic>> initList = new List<Map<String, dynamic>>();
      initList.add(toAdd);
      createBeaconsFile(initList, dir, savedBeaconsFileName);
    }
  }

  void _removeBeaconFromJsonFile(Beacon beacon) {
    print("Writing to file!");
    var jsonFileContent = json.decode(jsonFile.readAsStringSync());
    var toRemove;
    for (Map element in jsonFileContent) {
      if (element["proximityUUID"] == beacon.proximityUUID &&
          element["major"] == beacon.major &&
          element["minor"] == beacon.minor) toRemove = element;
    }
    if (toRemove != null) jsonFileContent.remove(toRemove);
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));
  }

  Future<void> _updateBeaconsList() async {
    var directory = await getApplicationDocumentsDirectory();
    jsonFile = new File(directory.path + "/" + savedBeaconsFileName);
    if (jsonFile.existsSync()) {
      _savedBeacons.clear();
      List info = json.decode(jsonFile.readAsStringSync());
      for (Map element in info) {
        _savedBeacons.add(Beacon(
          proximityUUID: element["proximityUUID"],
          major: element["major"],
          minor: element["minor"],
          macAddress: element["macAddress"],
          rssi: element["rssi"],
          txPower: element["txPower"],
          accuracy: element["accuracy"],
        ));
      }
    }
  }

  bool beaconIsSaved() {
    for (Beacon b in _savedBeacons) {
      if (b.proximityUUID == beacon.proximityUUID &&
          b.major == beacon.major &&
          b.minor == beacon.minor) return true;
    }
    return false;
  }
}
