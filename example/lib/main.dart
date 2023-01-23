import 'dart:typed_data';

import 'package:flutter/material.dart';
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
  final bt = TheLastBluetooth.instance;
  static const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  // Fallen into my own trap of "only first listen gets initial devices"
  List<BluetoothDevice> devices = [];
  BluetoothConnection? conn;

  @override
  void initState() {
    super.initState();
    bt.pairedDevicesStream.listen((event) {
      setState(() {
        devices = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              StreamBuilder(
                stream: bt.adapterInfoStream,
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? Text(snapshot.data.toString())
                      : const Text("No data");
                },
              ),
              const Text("paired devs (NEW 💯 - STREAM):"),
              // StreamBuilder<List<BluetoothDevice>>(
              //   stream: bt.pairedDevicesStream,
              //   initialData: [],
              //   builder: (context, snapshot) {
              //     if (snapshot.hasError) {
              //       return Text("error: ${snapshot.error}");
              //     }
              //     if (snapshot.hasData != true) return const Text("wait...");
              //     return Column(
              //       children: snapshot.data!
              //           .map((e) => Text(
              //                 "${e.name} ; "
              //                 "${e.alias ?? "null"} ; "
              //                 "${e.address} ; "
              //                 "${e.isConnected ? "✅" : "❌"}",
              //               ))
              //           .toList(),
              //     );
              //   },
              // ),

              // my own trap
              ...devices
                  .map((e) => Text(
                        "${e.name} ; "
                        "${e.alias ?? "null"} ; "
                        "${e.address} ; "
                        "${e.isConnected ? "✅" : "❌"}",
                      ))
                  .toList(),

              // @Shit("Temporary shitty code to test sending"
              TextButton(
                onPressed: () async {
                  try {
                    conn = await bt.connectRfcomm(
                        devices.firstWhere((e) => e.isConnected), sppUuid);
                    setState(() {});
                    await conn!.io.stream.listen(print).asFuture();
                    conn = null;
                    setState(() {});
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text("Connect"),
              ),
              if (conn != null)
                TextButton(
                  onPressed: () async {
                    await conn!.io.sink.close();
                    conn = null;
                    setState(() {});
                  },
                  child: Text("close"),
                ),
              if (conn != null)
                TextButton(
                  onPressed: () {
                    conn!.io.sink.add(Uint8List.fromList(
                        [90, 0, 7, 0, 43, 4, 1, 2, 1, -1, -1, -20]));
                  },
                  child: Text("send"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
