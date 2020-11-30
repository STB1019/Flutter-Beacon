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
              onPressed: () {
                createAlertDialog(context).then((value) {
                  if (value != null) {
                    setState(() {
                      addRegion(value);
                    });
                  }
                });
              },
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: savedRegions.length != 0
                ? _buildRegion()
                : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/not_found_icon.png',
                      color: ThemeBuilder.of(context).isDarkModeOn() ? Colors.white : Colors.black,
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
                      child: Text(
                        "Aggiungi una Regione",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                ]),
          ),
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<Region> createAlertDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController identifierController = TextEditingController();
    TextEditingController uuidController = TextEditingController();

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Add Region:"),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Theme.of(context).accentColor,
                  child: TextFormField(
                    controller: identifierController,
                  ),
                ),
                Card(
                  color: Theme.of(context).accentColor,
                  child: TextFormField(
                    controller: uuidController,
                  ),
                ),
                MaterialButton(
                  color: Theme.of(context).accentColor,
                  elevation: 5.0,
                  child: Text("Add"),
                  onPressed: () {
                    //customController is updated when the user inserts a text in the TextField,
                    //this variable contains what the user has written.
                    String newIdentifier = identifierController.text.toString();
                    String newUuid = uuidController.text.toString();
                    Region region = Region(identifier: newIdentifier, proximityUUID: newUuid);
                    Navigator.of(context).pop(region);
                  },
                )
              ],
            ),
        ),
      );
    });
  }

  void addRegion(Region region) => savedRegions.add(region);
}
