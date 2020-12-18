import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Beacon/app/beacon_page.dart';
import 'package:Beacon/app/theme.dart';

import 'package:Beacon/flutter_beacon/flutter_beacon.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'main_drawer.dart';

void main() => runApp(BeaconApp());

class BeaconApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
        builder: (context, _brightness, _primaryColor, _accentColor) {
      return MaterialApp(
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: _brightness,
          primaryColor: _primaryColor,
          accentColor: _accentColor,

          // Define the default font family.
          fontFamily: '',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            bodyText2: TextStyle(fontSize: 14.0),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

//WidgetsBindingObserver is needed for performance, to stop the app when it goes on background
class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  //this can be done only for android
  final _savedRegions = <Region>[];
  final _savedBeacons = <Beacon>[];
  String savedRegionsFileName = "saved_regions.json";
  String savedBeaconsFileName = "saved_beacons.json";
  List<MapEntry<Beacon, bool>> _lastScannedBeacons = new List();

  final StreamController<BluetoothState> streamController = StreamController();
  StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;

  //This method is executed first
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    listeningState();
    updateSavedInfo();
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

  //this method stops and starts the beacon scanning when i exit the application or when i reopen it
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

  //this method is called on initState() and checks the bluetooth state, then decides if it has to start scanning beacons
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

    if (!authorizationStatusOk ||
        !locationServiceEnabled ||
        !bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$authorizationStatusOk, '
          'locationServiceEnabled=$locationServiceEnabled, '
          'bluetoothEnabled=$bluetoothEnabled');
      return;
    }

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    //we have only an identifier, without a proximityUUID, so it works only for android and it ranges every beacon
    _streamRanging = flutterBeacon.ranging(
        <Region>[new Region(identifier: "")]).listen((RangingResult result) {
      // result contains a region and list of beacons found
      print(result);
      if (result != null && mounted) {
        setState(() {
          //adds to the variable _regionBeacon the found UUID's with the beacons
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
      setState(() {
        _beacons.clear();
      });
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);
    if (compare == 0) compare = a.major.compareTo(b.major);
    if (compare == 0) compare = a.minor.compareTo(b.minor);
    return compare;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: BeaconDrawer(),
      appBar: AppBar(
        title: Text("Beacon BLE Scanner"),
        actions: <Widget>[
          //When pressed, the app requests an authorization to access the device's location
          if (!authorizationStatusOk)
            IconButton(
                icon: Icon(Icons.portable_wifi_off),
                color: Colors.grey,
                onPressed: () async {
                  await flutterBeacon.requestAuthorization;
                }),
          //When pressed, opens the location settings
          if (!locationServiceEnabled)
            IconButton(
                icon: Icon(Icons.location_off),
                color: Colors.grey,
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
                    color: Colors.green,
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

      body: FutureBuilder(
          future: updateSavedInfo(),
          builder: (context, snapshot) {
            if (!authorizationStatusOk ||
                !locationServiceEnabled ||
                !bluetoothEnabled) return _authorizationRequestPage();
            if (snapshot.connectionState != ConnectionState.done)
              if(_lastScannedBeacons.isNotEmpty) return _buildBeaconFound(_lastScannedBeacons);
              else return Center(child: CircularProgressIndicator());
            if (_beacons == null){
              return Center(child: CircularProgressIndicator());
            }
            if (_beacons.isEmpty) {
              if (_savedBeacons.isNotEmpty) {
                return _buildBeaconFound(_getScannedBeacon());
              } else
                return Center(child: CircularProgressIndicator());
            } else
              return SafeArea(
                child: Container(
                  child: _buildBeaconFound(_getScannedBeacon()),
                ),
              );
          }),
    );
  }

  Future<void> updateSavedInfo() async {
    updateRegionList();
    updateBeaconList();
  }

  Future<void> updateRegionList() async {
    var directory = await getApplicationDocumentsDirectory();
    File jsonSavedRegionsFile =
        new File(directory.path + "/" + savedRegionsFileName);
    if (jsonSavedRegionsFile.existsSync()) {
      _savedRegions.clear();
      List info = json.decode(jsonSavedRegionsFile.readAsStringSync());
      for (Map element in info) {
        _savedRegions.add(Region(
            identifier: element["identifier"],
            proximityUUID: element["proximityUUID"]));
      }
    }
  }

  Future<void> updateBeaconList() async {
    var directory = await getApplicationDocumentsDirectory();
    File jsonSavedBeaconsFile =
        new File(directory.path + "/" + savedBeaconsFileName);
    if (jsonSavedBeaconsFile.existsSync()) {
      _savedBeacons.clear();
      List info = json.decode(jsonSavedBeaconsFile.readAsStringSync());
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

  List<MapEntry<Beacon, bool>> _getScannedBeacon(){
    //i delete the beacons in the regions that I'm not ranging
    final toRemove = <Beacon>[];
    for (Beacon beacon in _beacons) {
      bool isScanned = false;
      for (Region region in _savedRegions) {
        if (beacon.proximityUUID == region.proximityUUID) {
          isScanned = true;
          break;
        }
      }
      if (!isScanned) toRemove.add(beacon);
    }
    _beacons.removeWhere((element) => toRemove.contains(element));

    //Before adding the saved beacons, I build a "map" to recognize if the beacon is saved or not
    //I made a list of MapEntry because i can access the elements by index
    List<MapEntry<Beacon, bool>> beaconSavedMap = new List();
    beaconSavedMap.addAll(_beacons.map((e) => MapEntry(e, false)));

    for (Beacon saved in _savedBeacons) {
      bool toAdd = true;
      for (Beacon b in _beacons) {
        if (b.proximityUUID == saved.proximityUUID &&
            b.major == saved.major &&
            b.minor == saved.minor) {
          toAdd = false;
          break;
        }
      }
      if (toAdd) beaconSavedMap.add(new MapEntry(saved, true));
    }
    _lastScannedBeacons.clear();
    _lastScannedBeacons.addAll(beaconSavedMap);
    return beaconSavedMap;
  }

  Widget _buildBeaconFound(List<MapEntry<Beacon, bool>> beaconListWithSavedInfo) {
    if (beaconListWithSavedInfo.isEmpty) return Center(child: CircularProgressIndicator());
    return ListView.builder(
        itemCount: beaconListWithSavedInfo.length,
        itemBuilder: (context, index) {
          return Card(child: _buildRow(beaconListWithSavedInfo[index].key, beaconListWithSavedInfo[index].value));
        });
  }

  Widget _buildRow(Beacon beacon, bool isSaved) {
    return ListTile(
        leading: Icon(
          Icons.bluetooth_audio_rounded,
          color: isSaved ? Colors.grey : Colors.blue,
          size: 40,
        ),
        title: Text(
          beacon.macAddress,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Wrap(
          children: [
            Text('Accuracy: ' + beacon.accuracy.toString() + 'm, '),
            Text('RSSI: ' + beacon.rssi.toString()),
          ],
        ),
        onTap: () {
          setState(() {
            Region beaconRegion = new Region(identifier: "Unknown");
            for (Region element in _savedRegions) {
              if (beacon.proximityUUID == element.proximityUUID) {
                beaconRegion = element;
                break;
              }
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BeaconPage(beacon, beaconRegion)));
          });
        });
  }

  Widget _authorizationRequestPage() {
    return SafeArea(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/error_icon.png',
                color: Colors.amber[400],
                scale: 1.7,
              ),
            ),
            Center(
              child: Text(
                "Cannot scan Beacons",
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
                  "Allow location access and turn on the device's Bluetooth",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            )
          ]),
    );
  }
}
