class BluetoothDevice {
  final String name;

  BluetoothDevice(this.name);

  factory BluetoothDevice.fromMap(Map map) {
    return BluetoothDevice(map["name"]);
  }

  Map<String, dynamic> toMap() => {
        "name": name,
      };
}
