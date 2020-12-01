import 'dart:async';
import 'dart:io';

import 'package:Beacon/beacon_page.dart';
import 'package:Beacon/main_drawer.dart';
import 'package:Beacon/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

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
  final _savedRegions = <Region>[Region(identifier: 'gio', proximityUUID: "CB10023F-A318-3394-4199-A8730C7C1AEC")];

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

  //On android i can scan without knowing the UUID's
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

    /*if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: "mamma's beacons",
          proximityUUID: 'CB10023F-A318-3394-4199-A8730C7C1AEC'));
    } else {
      // android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon'));
    }*/
    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging = flutterBeacon.ranging(_savedRegions).listen((RangingResult result) {
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
      //drawer: BeaconDrawer(),
      drawer: BeaconDrawer(_savedRegions),
      appBar: AppBar(
        //backgroundColor: Theme.of(context).primaryColor,
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
                    //devo dare la possibilità di disabilitarlo
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

      //ONLY FOR TESTING GRAPHICS
      /*body: SafeArea(
           child: Card(
             child: _buildRow(Beacon(
               proximityUUID:
               'CB10023F-A318-3394-4199-A8730C7C1AEC',
               macAddress: '00:0a:95:9d:68:16',
               major: 3,
               minor: 41,
               rssi: -76,
               txPower: -60,
               accuracy: 2.43,
             )),
           ),
         ),*/

      body: (!authorizationStatusOk ||
              !locationServiceEnabled ||
              !bluetoothEnabled)
          ? _authorizationRequestPage()
          : (_beacons == null || _beacons.isEmpty)
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Container(
                    child: _buildBeaconFound(),
                  ),
                ),

      floatingActionButton: FloatingActionButton(onPressed: () { print(_savedRegions); },),

    );
  }

  Widget _buildBeaconFound() {
    return ListView.builder(
        itemCount: _beacons.length,
        itemBuilder: (context, index) {
          return Card(child: _buildRow(_beacons[index]));
        });
  }

  Widget _buildRow(Beacon beacon) {
    return ListTile(
        leading: Icon(
          Icons.bluetooth_audio_rounded,
          color: Colors.blue,
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BeaconPage(beacon)));
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
                "Impossibile eseguire la scansione",
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
                  "Consentire l'accesso alla localizzazione e attivare il Bluetooth del dispositivo",
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
