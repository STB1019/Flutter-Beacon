import 'dart:convert';
import 'dart:io';

import 'package:Beacon/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:Beacon/flutter_beacon/flutter_beacon.dart';
import 'package:path_provider/path_provider.dart';

class ManageRegionsPage extends StatefulWidget {
  ManageRegionsPage();

  @override
  _ManageRegionsPageState createState() => _ManageRegionsPageState();
}

class _ManageRegionsPageState extends State<ManageRegionsPage> {
  final savedRegions = <Region>[];

  String savedRegionsFileName = "saved_regions.json";
  File jsonFile;
  Directory dir;
  bool savedRegionsFileExists = false;

  _ManageRegionsPageState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + savedRegionsFileName);
      savedRegionsFileExists = jsonFile.existsSync();
    });
    if (savedRegionsFileExists) updateRegionList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Manage Regions"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addRegion(),
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: savedRegions.length != 0
                  ? _buildRegion()
                  : _showNoRegionsPage()),
        ));
  }

  Widget _showNoRegionsPage() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/not_found_icon.png',
              color: ThemeBuilder.of(context).isDarkModeOn()
                  ? Colors.white
                  : Colors.black,
              scale: 1.5,
            ),
          ),
          Center(
            child: Text(
              "Nessuna Regione salvata",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
            child: Center(
              child: MaterialButton(
                child: Text(
                  "Aggiungi una Regione",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                onPressed: () => _addRegion(),
              ),
            ),
          )
        ]);
  }

  Widget _buildRegion() {
    return ListView.builder(
        itemCount: savedRegions.length,
        itemBuilder: (context, index) {
          return Card(child: _buildRow(savedRegions[index]));
        });
  }

  Widget _buildRow(Region region) {
    return ListTile(
      title: Text(
        region.identifier,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        region.proximityUUID,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle_outline),
        onPressed: (){
          setState(() {
            savedRegions.remove(region);
            //c'è da fare un metodo apposito per toglierlo dal json
          });
        },
      ),
    );
  }

  Future<Region> _createRegionAlertDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();

    TextEditingController identifierController = TextEditingController();
    TextEditingController uuidController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Add Region:"),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                                'Indentifier: Name assigned to the Region.\n\n'
                                'UUID stands for Universally Unique Identifier.\n'
                                'It contains 32 hexadecimal digits, split into 5 groups, separated by hyphens'),
                          );
                        });
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        validator: (String value) {
                          if (value.length == 0)
                            return "Identifier can't be null";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Identifier",
                          labelStyle: TextStyle(),
                          border: OutlineInputBorder(),
                        ),
                        controller: identifierController,
                        maxLength: 30,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        validator: (String value) {
                          if (value.length != 32)
                            return "UUID must be 32 chars long";
                          RegExp exp = new RegExp(r"([0-9a-fA-F]){32}$");
                          if (!exp.hasMatch(value))
                            return "Insert hexadecimal chars only";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Proximity UUID",
                          labelStyle: TextStyle(),
                          border: OutlineInputBorder(),
                        ),
                        controller: uuidController,
                        maxLength: 32,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: MaterialButton(
                        color: Theme.of(context).accentColor,
                        child: Text("Add"),
                        onPressed: () {
                          //setState(){}? serve o no?
                          if (_formKey.currentState.validate()) {
                            String newIdentifier =
                                identifierController.text.toString();
                            String newUuid = uuidController.text.toString();
                            newUuid = newUuid.substring(0, 7).toUpperCase() +
                                "-" +
                                newUuid.substring(7, 11).toUpperCase() +
                                "-" +
                                newUuid.substring(11, 15).toUpperCase() +
                                "-" +
                                newUuid.substring(15, 19).toUpperCase() +
                                "-" +
                                newUuid.substring(20).toUpperCase();

                            Region region = Region(
                                identifier: newIdentifier,
                                proximityUUID: newUuid);
                            Navigator.of(context).pop(region);
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _addRegion() {
    _createRegionAlertDialog(context).then((value) {
      if (value != null) {
        setState(() {
          addRegionToJsonFile(value);
          updateRegionList();
        });
      }
    });
  }

  void createRegionsFile(
      List<Map<String, dynamic>> content, Directory dir, String fileName) {
    print("Creating file!");
    jsonFile = new File(dir.path + "/" + fileName);
    jsonFile.createSync();
    setState(() {
      savedRegionsFileExists = true;
    });
    savedRegionsFileExists = true;
    jsonFile.writeAsStringSync(json.encode(content));
  }

  void addRegionToJsonFile(Region region) {
    print("Writing to file!");
    Map<String, dynamic> toAdd = {
      'identifier': region.identifier,
      'proximityUUID': region.proximityUUID
    };

    if (savedRegionsFileExists) {
      print("File exists");
      var jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.add(toAdd);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    }
    if (!savedRegionsFileExists) {
      print("File doesn't exist");
      List<Map<String, dynamic>> initList = new List<Map<String, dynamic>>();
      initList.add(toAdd);
      createRegionsFile(initList, dir, savedRegionsFileName);
    }

    var fileContent = json.decode(jsonFile.readAsStringSync());
    print(
        "---------------\n" + fileContent.toString() + "\n----------------\n");
  }

  void updateRegionList() {
    savedRegions.clear();
    List info = json.decode(jsonFile.readAsStringSync());
    for (Map element in info) {
      savedRegions.add(Region(
          identifier: element["identifier"],
          proximityUUID: element["proximityUUID"]));
    }
  }
}
