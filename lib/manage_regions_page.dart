import 'package:Beacon/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

class ManageRegionsPage extends StatefulWidget {
  final List<Region> _savedRegions;

  ManageRegionsPage(this._savedRegions);

  @override
  _ManageRegionsPageState createState() =>
      _ManageRegionsPageState(_savedRegions);
}

class _ManageRegionsPageState extends State<ManageRegionsPage> {
  final List<Region> savedRegions;

  _ManageRegionsPageState(this.savedRegions);

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
    );
  }

  void _addRegion(){
    _createRegionAlertDialog(context).then((value) {
      if (value != null) {
        setState(() {
          savedRegions.add(value);
        });
      }
    });
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
                                'Indentifier: Name assigned to the Region.'
                                'UUID stands for Universally Unique Identifier.'
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
                                proximityUUID: newUuid
                            );
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

  Column _showNoRegionsPage() {
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

}
