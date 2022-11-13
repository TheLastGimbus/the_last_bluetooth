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

  @override
  String toString() =>
      'BluetoothDevice("$name" (alias: "$alias"), $address, ${isConnected ? 'connected✅' : 'disconnected❌'})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDevice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          alias == other.alias &&
          address == other.address &&
          isConnected == other.isConnected;

  @override
  int get hashCode =>
      name.hashCode ^ alias.hashCode ^ address.hashCode ^ isConnected.hashCode;
}
