class BluetoothDevice {
  final String name;
  final String? alias;
  final String address;
  final bool isConnected;

  const BluetoothDevice(
    this.name,
    this.alias,
    this.address,
    this.isConnected,
  );

  factory BluetoothDevice.fromMap(Map map) {
    return BluetoothDevice(
      map["name"],
      map["alias"],
      map["address"],
      map["isConnected"],
    );
  }

  Map<String, dynamic> toMap() => {
        "name": name,
        "alias": alias,
        "address": address,
        "isConnected": isConnected,
      };
}
