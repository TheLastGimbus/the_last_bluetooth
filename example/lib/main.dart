import 'package:bluetooth_identifiers/bluetooth_identifiers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<TheLastBluetooth> _bt;

  @override
  void initState() {
    super.initState();
    _bt = Permission.bluetoothConnect
        .request()
        .then((value) => TheLastBluetooth.instance);
    _bt.then((bt) async {
      final otter =
          await bt.pairedDevices.firstWhere((all) => all.isNotEmpty).then(
                (all) => all.firstWhereOrNull(
                    (dev) => dev.name.valueOrNull == 'HUAWEI FreeBuds 4i'),
              );
      if (otter != null) {
        Future.delayed(Duration(seconds: 10)).then((value) async {
          bt
              .connectRfcomm(otter, "00001101-0000-1000-8000-00805f9b34fb")
              .stream
              .listen((event) {
            print('WOOO: $event');
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _bt,
        builder: (_, snapBt) => Scaffold(
          appBar: AppBar(
            title: snapBt.hasData
                ? StreamBuilder(
                    stream: snapBt.data!.isEnabled,
                    builder: (_, snap) => Text(
                        "Bluetooth ${snap.hasData ? (snap.data! ? 'enabled ✅' : 'disabled ❌') : 'null'}"),
                  )
                : const Text('Loading...'),
          ),
          body: ListView(
            children: [
              snapBt.hasData
                  ? StreamBuilder(
                      stream: snapBt.data!.pairedDevices,
                      builder: (_, snap) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snap.hasData)
                            for (final dev in snap.data!)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      StreamBuilder(
                                        stream: dev.alias,
                                        builder: (_, snap) =>
                                            Text(snap.data ?? 'null'),
                                      ),
                                      const Text(' '),
                                      StreamBuilder(
                                        stream: dev.isConnected,
                                        builder: (_, snap) => Text(
                                          snap.data != null
                                              ? (snap.data! ? '✅' : '❌')
                                              : 'null',
                                        ),
                                      ),
                                      const Text(' '),
                                      StreamBuilder(
                                        stream: dev.battery,
                                        builder: (_, snap) => Text(
                                          snap.data != null
                                              ? '🔋${snap.data}%'
                                              : '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  FutureBuilder(
                                    future: dev.uuids,
                                    builder: (_, snap) => Column(
                                      children: [
                                        if (snap.hasData)
                                          Text(
                                            snap.data!
                                                .map((uuid) =>
                                                    BluetoothIdentifiers
                                                        .uuidServiceIdentifiers[
                                                            int.parse(
                                                                uuid.substring(
                                                                    4, 8),
                                                                radix: 16)]
                                                        ?.registrant ??
                                                    'null')
                                                .join(', '),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    )
                  : const Text('Requesting permission...')
            ],
          ),
        ),
      ),
    );
  }
}
