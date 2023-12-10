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
          title: StreamBuilder(
            stream: bt.isEnabled,
            builder: (_, snap) => Text(
                "Bluetooth ${snap.hasData ? (snap.data! ? 'enabled ✅' : 'disabled ❌') : 'null'}"),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: bt.pairedDevices,
                  builder: (_, snap) => Column(
                    children: [
                      if (snap.hasData)
                        for (final dev in snap.data!)
                          Text(dev.name.valueOrNull ?? 'null'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
