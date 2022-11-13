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

  @override
  void initState() {
    super.initState();
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
              StreamBuilder<List<BluetoothDevice>>(
                stream: bt.pairedDevicesStream,
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("error: ${snapshot.error}");
                  }
                  if (snapshot.hasData != true) return const Text("wait...");
                  return Column(
                    children: snapshot.data!
                        .map((e) => Text(
                              "${e.name} ; "
                              "${e.alias ?? "null"} ; "
                              "${e.address} ; "
                              "${e.isConnected ? "✅" : "❌"}",
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
