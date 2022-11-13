class BluetoothAdapter {
  final bool isAvailable;
  final bool isEnabled;
  final String? name;
  final String? address;

  BluetoothAdapter(
    this.isAvailable,
    this.isEnabled,
    this.name,
    this.address,
  );

  factory BluetoothAdapter.fromMap(Map map) {
    return BluetoothAdapter(
      map["isAvailable"],
      map["isEnabled"],
      map["name"],
      map["address"],
    );
  }

  Map<String, dynamic> toMap() => {
        "isAvailable": isAvailable,
        "isEnabled": isEnabled,
        "name": name,
        "address": address,
      };

  @override
  String toString() => isAvailable
      ? 'BluetoothAdapter(${isEnabled ? 'enabled✅' : 'disabled❌'}, name: "$name", $address)'
      : 'BluetoothAdapter(unavailable🙅)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothAdapter &&
          runtimeType == other.runtimeType &&
          isAvailable == other.isAvailable &&
          isEnabled == other.isEnabled &&
          name == other.name &&
          address == other.address;

  @override
  int get hashCode =>
      isAvailable.hashCode ^
      isEnabled.hashCode ^
      name.hashCode ^
      address.hashCode;
}
