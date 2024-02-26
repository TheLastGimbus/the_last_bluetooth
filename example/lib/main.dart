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
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  snapBt.hasData
                      ? StreamBuilder(
                          stream: snapBt.data!.pairedDevices,
                          builder: (_, snap) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (snap.hasData)
                                for (final dev in snap.data!)
                                  Row(
                                    children: [
                                      StreamBuilder(
                                        stream: dev.name,
                                        builder: (_, snap) =>
                                            Text(snap.data ?? 'null'),
                                      ),
                                      const Text(' aka '),
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
                                                : 'null'),
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
        ),
      ),
    );
  }
}
