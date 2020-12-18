import 'dart:convert';
import 'dart:io';

import 'package:Beacon/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:Beacon/flutter_beacon/flutter_beacon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';

class ManageRegionsPage extends StatefulWidget {
  ManageRegionsPage();

  @override
  _ManageRegionsPageState createState() => _ManageRegionsPageState();
}

class _ManageRegionsPageState extends State<ManageRegionsPage> {
  _ManageRegionsPageState();

  final savedRegions = <Region>[];
  String savedRegionsFileName = "saved_regions.json";
  File jsonFile;
  Directory dir;
  bool savedRegionsFileExists = false;

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + savedRegionsFileName);
      savedRegionsFileExists = jsonFile.existsSync();
      if (savedRegionsFileExists) _updateRegionList();
    });
    super.initState();
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
            child: FutureBuilder(
              future: _checkSavedRegions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data) return _buildRegion();
                  return _showNoRegionsPage();
                } else
                  return CircularProgressIndicator();
              },
            ),
          ),
        ));
  }

  Future<bool> _checkSavedRegions() async {
    var directory = await getApplicationDocumentsDirectory();
    jsonFile = new File(directory.path + "/" + savedRegionsFileName);
    if (jsonFile.existsSync()) _updateRegionList();
    if (savedRegions.length > 0) return true;
    return false;
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
              scale: 1.4,
            ),
          ),
          Center(
            child: Text(
              "No Region saved",
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
                  "Add Region",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onPressed: () => _addRegion(),
              ),
            ),
          )
        ]);
  }

  Widget _buildRegion() {
    return ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: savedRegions.length,
        itemBuilder: (context, index) {
          return _buildRow(savedRegions[index]);
        });
  }

  Widget _buildRow(Region region) {
    return Dismissible(
      key: ObjectKey(region),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _removeRegion(region);
        });
      },
      background: Container(
        color: Colors.red[400],
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FaIcon(
            FontAwesomeIcons.trash,
            color: Colors.white,
          ),
        ),
      ),
      child: ListTile(
        onLongPress: () {
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: GestureDetector(
                    child: Text("Delete Region"),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _removeRegion(region);
                        _updateRegionList();
                      });
                    },
                  ),
                );
              });
        },
        title: RichText(
          text: TextSpan(
              text: "Identifier: ",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontSize: 18,
                //fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: region.identifier,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
        ),
        subtitle: Text(
          region.proximityUUID,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                          if (value.length > 16)
                            return "Id must have max 16 chars";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Identifier",
                          labelStyle: TextStyle(),
                          border: OutlineInputBorder(),
                        ),
                        controller: identifierController,
                        maxLength: 16,
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
                            newUuid = newUuid.substring(0, 8).toUpperCase() +
                                "-" +
                                newUuid.substring(8, 12).toUpperCase() +
                                "-" +
                                newUuid.substring(12, 16).toUpperCase() +
                                "-" +
                                newUuid.substring(16, 20).toUpperCase() +
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
          _addRegionToJsonFile(value);
          _updateRegionList();
        });
      }
    });
  }

  void _removeRegion(Region r) {
    print("Writing to file!");
    var jsonFileContent = json.decode(jsonFile.readAsStringSync());
    var toRemove;
    for (Map element in jsonFileContent) {
      if (element["identifier"] == r.identifier &&
          element["proximityUUID"] == r.proximityUUID) toRemove = element;
    }
    if (toRemove != null) jsonFileContent.remove(toRemove);
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));
  }

  void createRegionsFile(
      List<Map<String, dynamic>> content, Directory dir, String fileName) {
    print("Creating file!");
    jsonFile = new File(dir.path + "/" + fileName);
    jsonFile.createSync();
    setState(() {
      savedRegionsFileExists = true;
    });
    jsonFile.writeAsStringSync(json.encode(content));
  }

  void _addRegionToJsonFile(Region region) {
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
  }

  void _updateRegionList() {
    savedRegions.clear();
    List info = json.decode(jsonFile.readAsStringSync());
    for (Map element in info) {
      savedRegions.add(Region(
          identifier: element["identifier"],
          proximityUUID: element["proximityUUID"]));
    }
  }
}
