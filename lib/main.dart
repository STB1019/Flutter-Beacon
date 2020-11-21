import 'dart:async';
import 'dart:io';

import 'package:Beacon/beaconPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

void main() => runApp(BeaconApp());

class BeaconApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.deepPurpleAccent,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

//I need a stateful widget because screen is going to change if we find a new Beacon
class HomePage extends StatefulWidget {
  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{

  final StreamController<BluetoothState> streamController = StreamController();
  StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;

  final _beaconName = <String>["Giulio", "Giorgio", "Marco", "Paolo"];
  final _selectedBeacons = Set<String>();
  Color cardColor;

  //This method is executed first
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    listeningState();
  }


  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      print('BluetoothState = $state');
      streamController.add(state);

      switch (state) {
        case BluetoothState.stateOn:
          initScanBeacon();
          break;
        case BluetoothState.stateOff:
          await pauseScanBeacon();
          await checkAllRequirements();
          break;
      }
    });
  }

  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
    await flutterBeacon.checkLocationServicesIfEnabled;

    setState(() {
      this.authorizationStatusOk = authorizationStatusOk;
      this.locationServiceEnabled = locationServiceEnabled;
      this.bluetoothEnabled = bluetoothEnabled;
    });
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();

    if (!authorizationStatusOk || !locationServiceEnabled || !bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$authorizationStatusOk, '
          'locationServiceEnabled=$locationServiceEnabled, '
          'bluetoothEnabled=$bluetoothEnabled');
      return;
    }
    final regions = <Region>[
      Region(
        identifier: 'Cubeacon',
        proximityUUID: 'CB10023F-A318-3394-4199-A8730C7C1AEC',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
          print(result);
          if (result != null && mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;
              _beacons.clear();
              _regionBeacons.values.forEach((list) {
                _beacons.addAll(list);
              });
              _beacons.sort(_compareParameters);
            });
          }
        });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {_beacons.clear();}
      );
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);
    if (compare == 0) compare = a.major.compareTo(b.major);
    if (compare == 0) compare = a.minor.compareTo(b.minor);
    return compare;
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null && _streamBluetooth.isPaused) {
        _streamBluetooth.resume();
      }
      await checkAllRequirements();
      if (authorizationStatusOk && locationServiceEnabled && bluetoothEnabled) {
        await initScanBeacon();
      } else {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamController?.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Text("Beacon BLE"),
        actions: <Widget>[
          //When pressed, the app requests an authorization to access the device's location
          if (!authorizationStatusOk)
            IconButton(
                icon: Icon(Icons.portable_wifi_off),
                color: Colors.blueGrey,
                onPressed: () async {
                  await flutterBeacon.requestAuthorization;
                }),
          //When pressed, opens the location settings
          if (!locationServiceEnabled)
            IconButton(
                icon: Icon(Icons.location_off),
                color: Colors.red,
                onPressed: () async {
                  if (Platform.isAndroid) {
                    await flutterBeacon.openLocationSettings;
                  } else if (Platform.isIOS) {}
                }),

          StreamBuilder<BluetoothState>(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final state = snapshot.data;
                if (state == BluetoothState.stateOn) {
                  return IconButton(
                    icon: Icon(Icons.bluetooth_connected),
                    onPressed: () {},
                    color: Colors.lightGreen,
                  );
                }
                if (state == BluetoothState.stateOff) {
                  return IconButton(
                    icon: Icon(Icons.bluetooth),
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        try {
                          await flutterBeacon.openBluetoothSettings;
                        } on PlatformException catch (e) {
                          print(e);
                        }
                      } else if (Platform.isIOS) {}
                    },
                    color: Colors.blueGrey,
                  );
                }

                return IconButton(
                  icon: Icon(Icons.bluetooth_disabled),
                  onPressed: () {},
                  color: Colors.grey,
                );
              }

              return SizedBox.shrink();
            },
            stream: streamController.stream,
            initialData: BluetoothState.stateUnknown,
          ),
        ],
      ),


      body: _beacons == null || _beacons.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: ListTile.divideTiles(
            context: context,
            tiles: _beacons.map((beacon) {
              return ListTile(
                title: Text(beacon.proximityUUID),
                subtitle: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                        child: Text(
                            'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                            style: TextStyle(fontSize: 13.0)),
                        flex: 1,
                        fit: FlexFit.tight),
                    Flexible(
                        child: Text(
                            'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                            style: TextStyle(fontSize: 13.0)),
                        flex: 2,
                        fit: FlexFit.tight)
                  ],
                ),
              );
            })).toList(),
      ),


      //body: Container(
        //child: _buildBeaconFound(),
      //),


    );
  }

  Widget _buildBeaconFound() {
    return ListView.builder(
        itemCount: _beaconName.length,
        itemBuilder: (context, index) {
          return Card(child: _buildRow(_beaconName[index]));
        });
  }

  Widget _buildRow(String text) {
    final selected = _selectedBeacons.contains(text);
    return ListTile(
        leading: FlutterLogo(
          size: 40,
        ),
        title: Text("Beacon"),
        subtitle: Text("name: " + text.toString()),
        trailing: GestureDetector(
          onTap: () {
            setState(() {
              if (selected)
                _selectedBeacons.remove(text);
              else
                _selectedBeacons.add(text);
            });
          },
          child: Icon(
            selected ? Icons.wb_sunny : Icons.wb_sunny_outlined,
            color: selected ? Colors.amber : null,
          ),
        ),
        tileColor: cardColor,
        onTap: () {
          setState(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BeaconPage(text.toString())));
          });
        });
  }
}
