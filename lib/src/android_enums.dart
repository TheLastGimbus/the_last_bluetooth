// ignore_for_file: constant_identifier_names, doc_directive_unknown, slash_for_doc_comments

abstract class BluetoothAdapter {
  /**
   * Broadcast Action: The state of the local Bluetooth adapter has been
   * changed.
   * <p>For example, Bluetooth has been turned on or off.
   * <p>Always contains the extra fields {@link #EXTRA_STATE} and {@link
   * #EXTRA_PREVIOUS_STATE} containing the new and old states
   * respectively.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_STATE_CHANGED =
      "android.bluetooth.adapter.action.STATE_CHANGED";

  /**
   * Used as an int extra field in {@link #ACTION_STATE_CHANGED}
   * intents to request the current power state. Possible values are:
   * {@link #STATE_OFF},
   * {@link #STATE_TURNING_ON},
   * {@link #STATE_ON},
   * {@link #STATE_TURNING_OFF},
   */
  static const String EXTRA_STATE = "android.bluetooth.adapter.extra.STATE";

  /**
   * Used as an int extra field in {@link #ACTION_STATE_CHANGED}
   * intents to request the previous power state. Possible values are:
   * {@link #STATE_OFF},
   * {@link #STATE_TURNING_ON},
   * {@link #STATE_ON},
   * {@link #STATE_TURNING_OFF},
   */
  static const String EXTRA_PREVIOUS_STATE =
      "android.bluetooth.adapter.extra.PREVIOUS_STATE";

  /**
   * Indicates the local Bluetooth adapter is off.
   */
  static const int STATE_OFF = 10;

  /**
   * Indicates the local Bluetooth adapter is turning on. However local
   * clients should wait for {@link #STATE_ON} before attempting to
   * use the adapter.
   */
  static const int STATE_TURNING_ON = 11;

  /**
   * Indicates the local Bluetooth adapter is on, and ready for use.
   */
  static const int STATE_ON = 12;

  /**
   * Indicates the local Bluetooth adapter is turning off. Local clients
   * should immediately attempt graceful disconnection of any remote links.
   */
  static const int STATE_TURNING_OFF = 13;

  /**
   * Activity Action: Show a system activity that requests discoverable mode.
   * This activity will also request the user to turn on Bluetooth if it
   * is not currently enabled.
   * <p>Discoverable mode is equivalent to {@link
   * #SCAN_MODE_CONNECTABLE_DISCOVERABLE}. It allows remote devices to see
   * this Bluetooth adapter when they perform a discovery.
   * <p>For privacy, Android is not discoverable by default.
   * <p>The sender of this Intent can optionally use extra field {@link
   * #EXTRA_DISCOVERABLE_DURATION} to request the duration of
   * discoverability. Currently the default duration is 120 seconds, and
   * maximum duration is capped at 300 seconds for each request.
   * <p>Notification of the result of this activity is posted using the
   * {@link android.app.Activity#onActivityResult} callback. The
   * <code>resultCode</code>
   * will be the duration (in seconds) of discoverability or
   * {@link android.app.Activity#RESULT_CANCELED} if the user rejected
   * discoverability or an error has occurred.
   * <p>Applications can also listen for {@link #ACTION_SCAN_MODE_CHANGED}
   * for global notification whenever the scan mode changes. For example, an
   * application can be notified when the device has ended discoverability.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH}
   */

  static const String ACTION_REQUEST_DISCOVERABLE =
      "android.bluetooth.adapter.action.REQUEST_DISCOVERABLE";

  /**
   * Used as an optional int extra field in {@link
   * #ACTION_REQUEST_DISCOVERABLE} intents to request a specific duration
   * for discoverability in seconds. The current default is 120 seconds, and
   * requests over 300 seconds will be capped. These values could change.
   */
  static const String EXTRA_DISCOVERABLE_DURATION =
      "android.bluetooth.adapter.extra.DISCOVERABLE_DURATION";

  /**
   * Activity Action: Show a system activity that allows the user to turn on
   * Bluetooth.
   * <p>This system activity will return once Bluetooth has completed turning
   * on, or the user has decided not to turn Bluetooth on.
   * <p>Notification of the result of this activity is posted using the
   * {@link android.app.Activity#onActivityResult} callback. The
   * <code>resultCode</code>
   * will be {@link android.app.Activity#RESULT_OK} if Bluetooth has been
   * turned on or {@link android.app.Activity#RESULT_CANCELED} if the user
   * has rejected the request or an error has occurred.
   * <p>Applications can also listen for {@link #ACTION_STATE_CHANGED}
   * for global notification whenever Bluetooth is turned on or off.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH}
   */

  static const String ACTION_REQUEST_ENABLE =
      "android.bluetooth.adapter.action.REQUEST_ENABLE";

  /**
   * Broadcast Action: Indicates the Bluetooth scan mode of the local Adapter
   * has changed.
   * <p>Always contains the extra fields {@link #EXTRA_SCAN_MODE} and {@link
   * #EXTRA_PREVIOUS_SCAN_MODE} containing the new and old scan modes
   * respectively.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH}
   */

  static const String ACTION_SCAN_MODE_CHANGED =
      "android.bluetooth.adapter.action.SCAN_MODE_CHANGED";

  /**
   * Used as an int extra field in {@link #ACTION_SCAN_MODE_CHANGED}
   * intents to request the current scan mode. Possible values are:
   * {@link #SCAN_MODE_NONE},
   * {@link #SCAN_MODE_CONNECTABLE},
   * {@link #SCAN_MODE_CONNECTABLE_DISCOVERABLE},
   */
  static const String EXTRA_SCAN_MODE =
      "android.bluetooth.adapter.extra.SCAN_MODE";

  /**
   * Used as an int extra field in {@link #ACTION_SCAN_MODE_CHANGED}
   * intents to request the previous scan mode. Possible values are:
   * {@link #SCAN_MODE_NONE},
   * {@link #SCAN_MODE_CONNECTABLE},
   * {@link #SCAN_MODE_CONNECTABLE_DISCOVERABLE},
   */
  static const String EXTRA_PREVIOUS_SCAN_MODE =
      "android.bluetooth.adapter.extra.PREVIOUS_SCAN_MODE";

  /**
   * Indicates that both inquiry scan and page scan are disabled on the local
   * Bluetooth adapter. Therefore this device is neither discoverable
   * nor connectable from remote Bluetooth devices.
   */
  static const int SCAN_MODE_NONE = 20;

  /**
   * Indicates that inquiry scan is disabled, but page scan is enabled on the
   * local Bluetooth adapter. Therefore this device is not discoverable from
   * remote Bluetooth devices, but is connectable from remote devices that
   * have previously discovered this device.
   */
  static const int SCAN_MODE_CONNECTABLE = 21;

  /**
   * Indicates that both inquiry scan and page scan are enabled on the local
   * Bluetooth adapter. Therefore this device is both discoverable and
   * connectable from remote Bluetooth devices.
   */
  static const int SCAN_MODE_CONNECTABLE_DISCOVERABLE = 23;

  /**
   * Broadcast Action: The local Bluetooth adapter has started the remote
   * device discovery process.
   * <p>This usually involves an inquiry scan of about 12 seconds, followed
   * by a page scan of each new device to retrieve its Bluetooth name.
   * <p>Register for {@link BluetoothDevice#ACTION_FOUND} to be notified as
   * remote Bluetooth devices are found.
   * <p>Device discovery is a heavyweight procedure. New connections to
   * remote Bluetooth devices should not be attempted while discovery is in
   * progress, and existing connections will experience limited bandwidth
   * and high latency. Use {@link #cancelDiscovery()} to cancel an ongoing
   * discovery.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_DISCOVERY_STARTED =
      "android.bluetooth.adapter.action.DISCOVERY_STARTED";

  /**
   * Broadcast Action: The local Bluetooth adapter has finished the device
   * discovery process.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_DISCOVERY_FINISHED =
      "android.bluetooth.adapter.action.DISCOVERY_FINISHED";

  /**
   * Broadcast Action: The local Bluetooth adapter has changed its friendly
   * Bluetooth name.
   * <p>This name is visible to remote Bluetooth devices.
   * <p>Always contains the extra field {@link #EXTRA_LOCAL_NAME} containing
   * the name.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_LOCAL_NAME_CHANGED =
      "android.bluetooth.adapter.action.LOCAL_NAME_CHANGED";

  /**
   * Used as a String extra field in {@link #ACTION_LOCAL_NAME_CHANGED}
   * intents to request the local Bluetooth name.
   */
  static const String EXTRA_LOCAL_NAME =
      "android.bluetooth.adapter.extra.LOCAL_NAME";

  /**
   * Intent used to broadcast the change in connection state of the local
   * Bluetooth adapter to a profile of the remote device. When the adapter is
   * not connected to any profiles of any remote devices and it attempts a
   * connection to a profile this intent will sent. Once connected, this intent
   * will not be sent for any more connection attempts to any profiles of any
   * remote device. When the adapter disconnects from the last profile its
   * connected to of any remote device, this intent will be sent.
   *
   * <p> This intent is useful for applications that are only concerned about
   * whether the local adapter is connected to any profile of any device and
   * are not really concerned about which profile. For example, an application
   * which displays an icon to display whether Bluetooth is connected or not
   * can use this intent.
   *
   * <p>This intent will have 3 extras:
   * {@link #EXTRA_CONNECTION_STATE} - The current connection state.
   * {@link #EXTRA_PREVIOUS_CONNECTION_STATE}- The previous connection state.
   * {@link BluetoothDevice#EXTRA_DEVICE} - The remote device.
   *
   * {@link #EXTRA_CONNECTION_STATE} or {@link #EXTRA_PREVIOUS_CONNECTION_STATE}
   * can be any of {@link #STATE_DISCONNECTED}, {@link #STATE_CONNECTING},
   * {@link #STATE_CONNECTED}, {@link #STATE_DISCONNECTING}.
   *
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_CONNECTION_STATE_CHANGED =
      "android.bluetooth.adapter.action.CONNECTION_STATE_CHANGED";

  /**
   * Extra used by {@link #ACTION_CONNECTION_STATE_CHANGED}
   *
   * This extra represents the current connection state.
   */
  static const String EXTRA_CONNECTION_STATE =
      "android.bluetooth.adapter.extra.CONNECTION_STATE";

  /**
   * Extra used by {@link #ACTION_CONNECTION_STATE_CHANGED}
   *
   * This extra represents the previous connection state.
   */
  static const String EXTRA_PREVIOUS_CONNECTION_STATE =
      "android.bluetooth.adapter.extra.PREVIOUS_CONNECTION_STATE";

  /** The profile is in disconnected state */
  static const int STATE_DISCONNECTED = 0;

  /** The profile is in connecting state */
  static const int STATE_CONNECTING = 1;

  /** The profile is in connected state */
  static const int STATE_CONNECTED = 2;

  /** The profile is in disconnecting state */
  static const int STATE_DISCONNECTING = 3;

  /** @hide */
  static const String BLUETOOTH_MANAGER_SERVICE = "bluetooth_manager";
}

abstract class BluetoothDevice {
  // !!! SECRET COMMANDS !!! 😋
  // They're not anywhere in documentation
  // ohhhh i fucking love android
  static const ACTION_BATTERY_LEVEL_CHANGED =
      "android.bluetooth.device.action.BATTERY_LEVEL_CHANGED";
  static const EXTRA_BATTERY_LEVEL =
      "android.bluetooth.device.extra.BATTERY_LEVEL";

  /**
   * Broadcast Action: Remote device discovered.
   * <p>Sent when a remote device is found during discovery.
   * <p>Always contains the extra fields {@link #EXTRA_DEVICE} and {@link
   * #EXTRA_CLASS}. Can contain the extra fields {@link #EXTRA_NAME} and/or
   * {@link #EXTRA_RSSI} if they are available.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_FOUND = "android.bluetooth.device.action.FOUND";

  /**
   * Broadcast Action: Remote device disappeared.
   * <p>Sent when a remote device that was found in the last discovery is not
   * found in the current discovery.
   * <p>Always contains the extra field {@link #EXTRA_DEVICE}.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   * @hide
   */

  static const String ACTION_DISAPPEARED =
      "android.bluetooth.device.action.DISAPPEARED";

  /**
   * Broadcast Action: Bluetooth class of a remote device has changed.
   * <p>Always contains the extra fields {@link #EXTRA_DEVICE} and {@link
   * #EXTRA_CLASS}.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   * {@see BluetoothClass}
   */

  static const String ACTION_CLASS_CHANGED =
      "android.bluetooth.device.action.CLASS_CHANGED";

  /**
   * Broadcast Action: Indicates a low level (ACL) connection has been
   * established with a remote device.
   * <p>Always contains the extra field {@link #EXTRA_DEVICE}.
   * <p>ACL connections are managed automatically by the Android Bluetooth
   * stack.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_ACL_CONNECTED =
      "android.bluetooth.device.action.ACL_CONNECTED";

  /**
   * Broadcast Action: Indicates that a low level (ACL) disconnection has
   * been requested for a remote device, and it will soon be disconnected.
   * <p>This is useful for graceful disconnection. Applications should use
   * this intent as a hint to immediately terminate higher level connections
   * (RFCOMM, L2CAP, or profile connections) to the remote device.
   * <p>Always contains the extra field {@link #EXTRA_DEVICE}.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_ACL_DISCONNECT_REQUESTED =
      "android.bluetooth.device.action.ACL_DISCONNECT_REQUESTED";

  /**
   * Broadcast Action: Indicates a low level (ACL) disconnection from a
   * remote device.
   * <p>Always contains the extra field {@link #EXTRA_DEVICE}.
   * <p>ACL connections are managed automatically by the Android Bluetooth
   * stack.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_ACL_DISCONNECTED =
      "android.bluetooth.device.action.ACL_DISCONNECTED";

  /**
   * Broadcast Action: Indicates the friendly name of a remote device has
   * been retrieved for the first time, or changed since the last retrieval.
   * <p>Always contains the extra fields {@link #EXTRA_DEVICE} and {@link
   * #EXTRA_NAME}.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_NAME_CHANGED =
      "android.bluetooth.device.action.NAME_CHANGED";

  /**
   * Broadcast Action: Indicates the alias of a remote device has been
   * changed.
   * <p>Always contains the extra field {@link #EXTRA_DEVICE}.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   *
   * @hide
   */

  static const String ACTION_ALIAS_CHANGED =
      "android.bluetooth.device.action.ALIAS_CHANGED";

  /**
   * Broadcast Action: Indicates a change in the bond state of a remote
   * device. For example, if a device is bonded (paired).
   * <p>Always contains the extra fields {@link #EXTRA_DEVICE}, {@link
   * #EXTRA_BOND_STATE} and {@link #EXTRA_PREVIOUS_BOND_STATE}.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */
  // Note: When EXTRA_BOND_STATE is BOND_NONE then this will also
  // contain a hidden extra field EXTRA_REASON with the result code.

  static const String ACTION_BOND_STATE_CHANGED =
      "android.bluetooth.device.action.BOND_STATE_CHANGED";

  /**
   * Used as a Parcelable {@link BluetoothDevice} extra field in every intent
   * broadcast by this class. It contains the {@link BluetoothDevice} that
   * the intent applies to.
   */
  static const String EXTRA_DEVICE = "android.bluetooth.device.extra.DEVICE";

  /**
   * Used as a String extra field in {@link #ACTION_NAME_CHANGED} and {@link
   * #ACTION_FOUND} intents. It contains the friendly Bluetooth name.
   */
  static const String EXTRA_NAME = "android.bluetooth.device.extra.NAME";

  /**
   * Used as an optional short extra field in {@link #ACTION_FOUND} intents.
   * Contains the RSSI value of the remote device as reported by the
   * Bluetooth hardware.
   */
  static const String EXTRA_RSSI = "android.bluetooth.device.extra.RSSI";

  /**
   * Used as a Parcelable {@link BluetoothClass} extra field in {@link
   * #ACTION_FOUND} and {@link #ACTION_CLASS_CHANGED} intents.
   */
  static const String EXTRA_CLASS = "android.bluetooth.device.extra.CLASS";

  /**
   * Used as an int extra field in {@link #ACTION_BOND_STATE_CHANGED} intents.
   * Contains the bond state of the remote device.
   * <p>Possible values are:
   * {@link #BOND_NONE},
   * {@link #BOND_BONDING},
   * {@link #BOND_BONDED}.
   */
  static const String EXTRA_BOND_STATE =
      "android.bluetooth.device.extra.BOND_STATE";

  /**
   * Used as an int extra field in {@link #ACTION_BOND_STATE_CHANGED} intents.
   * Contains the previous bond state of the remote device.
   * <p>Possible values are:
   * {@link #BOND_NONE},
   * {@link #BOND_BONDING},
   * {@link #BOND_BONDED}.
   */
  static const String EXTRA_PREVIOUS_BOND_STATE =
      "android.bluetooth.device.extra.PREVIOUS_BOND_STATE";

  /**
   * Indicates the remote device is not bonded (paired).
   * <p>There is no shared link key with the remote device, so communication
   * (if it is allowed at all) will be unauthenticated and unencrypted.
   */
  static const int BOND_NONE = 10;

  /**
   * Indicates bonding (pairing) is in progress with the remote device.
   */
  static const int BOND_BONDING = 11;

  /**
   * Indicates the remote device is bonded (paired).
   * <p>A shared link keys exists locally for the remote device, so
   * communication can be authenticated and encrypted.
   * <p><i>Being bonded (paired) with a remote device does not necessarily
   * mean the device is currently connected. It just means that the pending
   * procedure was completed at some earlier time, and the link key is still
   * stored locally, ready to use on the next connection.
   * </i>
   */
  static const int BOND_BONDED = 12;

  /** @hide */
  static const String EXTRA_REASON = "android.bluetooth.device.extra.REASON";

  /** @hide */
  static const String EXTRA_PAIRING_VARIANT =
      "android.bluetooth.device.extra.PAIRING_VARIANT";

  /** @hide */
  static const String EXTRA_PAIRING_KEY =
      "android.bluetooth.device.extra.PAIRING_KEY";

  /**
   * Bluetooth device type, Unknown
   */
  static const int DEVICE_TYPE_UNKNOWN = 0;

  /**
   * Bluetooth device type, Classic - BR/EDR devices
   */
  static const int DEVICE_TYPE_CLASSIC = 1;

  /**
   * Bluetooth device type, Low Energy - LE-only
   */
  static const int DEVICE_TYPE_LE = 2;

  /**
   * Bluetooth device type, Dual Mode - BR/EDR/LE
   */
  static const int DEVICE_TYPE_DUAL = 3;

  /**
   * Broadcast Action: This intent is used to broadcast the {@link UUID}
   * wrapped as a {@link android.os.ParcelUuid} of the remote device after it
   * has been fetched. This intent is sent only when the UUIDs of the remote
   * device are requested to be fetched using Service Discovery Protocol
   * <p> Always contains the extra field {@link #EXTRA_DEVICE}
   * <p> Always contains the extra field {@link #EXTRA_UUID}
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   */

  static const String ACTION_UUID = "android.bluetooth.device.action.UUID";

  /**
   * Broadcast Action: Indicates a failure to retrieve the name of a remote
   * device.
   * <p>Always contains the extra field {@link #EXTRA_DEVICE}.
   * <p>Requires {@link android.Manifest.permission#BLUETOOTH} to receive.
   * @hide
   */

  static const String ACTION_NAME_FAILED =
      "android.bluetooth.device.action.NAME_FAILED";

  /** @hide */

  static const String ACTION_PAIRING_REQUEST =
      "android.bluetooth.device.action.PAIRING_REQUEST";

  /** @hide */

  static const String ACTION_PAIRING_CANCEL =
      "android.bluetooth.device.action.PAIRING_CANCEL";

  /** @hide */

  static const String ACTION_CONNECTION_ACCESS_REQUEST =
      "android.bluetooth.device.action.CONNECTION_ACCESS_REQUEST";

  /** @hide */

  static const String ACTION_CONNECTION_ACCESS_REPLY =
      "android.bluetooth.device.action.CONNECTION_ACCESS_REPLY";

  /** @hide */

  static const String ACTION_CONNECTION_ACCESS_CANCEL =
      "android.bluetooth.device.action.CONNECTION_ACCESS_CANCEL";

  /**
   * Used as an extra field in {@link #ACTION_CONNECTION_ACCESS_REQUEST} intent.
   * @hide
   */
  static const String EXTRA_ACCESS_REQUEST_TYPE =
      "android.bluetooth.device.extra.ACCESS_REQUEST_TYPE";

  /**@hide*/
  static const int REQUEST_TYPE_PROFILE_CONNECTION = 1;

  /**@hide*/
  static const int REQUEST_TYPE_PHONEBOOK_ACCESS = 2;

  /**
   * Used as an extra field in {@link #ACTION_CONNECTION_ACCESS_REQUEST} intents,
   * Contains package name to return reply intent to.
   * @hide
   */
  static const String EXTRA_PACKAGE_NAME =
      "android.bluetooth.device.extra.PACKAGE_NAME";

  /**
   * Used as an extra field in {@link #ACTION_CONNECTION_ACCESS_REQUEST} intents,
   * Contains class name to return reply intent to.
   * @hide
   */
  static const String EXTRA_CLASS_NAME =
      "android.bluetooth.device.extra.CLASS_NAME";

  /**
   * Used as an extra field in {@link #ACTION_CONNECTION_ACCESS_REPLY} intent.
   * @hide
   */
  static const String EXTRA_CONNECTION_ACCESS_RESULT =
      "android.bluetooth.device.extra.CONNECTION_ACCESS_RESULT";

  /**@hide*/
  static const int CONNECTION_ACCESS_YES = 1;

  /**@hide*/
  static const int CONNECTION_ACCESS_NO = 2;

  /**
   * Used as an extra field in {@link #ACTION_CONNECTION_ACCESS_REPLY} intents,
   * Contains boolean to indicate if the allowed response is once-for-all so that
   * next request will be granted without asking user again.
   * @hide
   */
  static const String EXTRA_ALWAYS_ALLOWED =
      "android.bluetooth.device.extra.ALWAYS_ALLOWED";

  /**
   * A bond attempt succeeded
   * @hide
   */
  static const int BOND_SUCCESS = 0;

  /**
   * A bond attempt failed because pins did not match, or remote device did
   * not respond to pin request in time
   * @hide
   */
  static const int UNBOND_REASON_AUTH_FAILED = 1;

  /**
   * A bond attempt failed because the other side explicitly rejected
   * bonding
   * @hide
   */
  static const int UNBOND_REASON_AUTH_REJECTED = 2;

  /**
   * A bond attempt failed because we canceled the bonding process
   * @hide
   */
  static const int UNBOND_REASON_AUTH_CANCELED = 3;

  /**
   * A bond attempt failed because we could not contact the remote device
   * @hide
   */
  static const int UNBOND_REASON_REMOTE_DEVICE_DOWN = 4;

  /**
   * A bond attempt failed because a discovery is in progress
   * @hide
   */
  static const int UNBOND_REASON_DISCOVERY_IN_PROGRESS = 5;

  /**
   * A bond attempt failed because of authentication timeout
   * @hide
   */
  static const int UNBOND_REASON_AUTH_TIMEOUT = 6;

  /**
   * A bond attempt failed because of repeated attempts
   * @hide
   */
  static const int UNBOND_REASON_REPEATED_ATTEMPTS = 7;

  /**
   * A bond attempt failed because we received an Authentication Cancel
   * by remote end
   * @hide
   */
  static const int UNBOND_REASON_REMOTE_AUTH_CANCELED = 8;

  /**
   * An existing bond was explicitly revoked
   * @hide
   */
  static const int UNBOND_REASON_REMOVED = 9;

  /**
   * The user will be prompted to enter a pin
   * @hide
   */
  static const int PAIRING_VARIANT_PIN = 0;

  /**
   * The user will be prompted to enter a passkey
   * @hide
   */
  static const int PAIRING_VARIANT_PASSKEY = 1;

  /**
   * The user will be prompted to confirm the passkey displayed on the screen
   * @hide
   */
  static const int PAIRING_VARIANT_PASSKEY_CONFIRMATION = 2;

  /**
   * The user will be prompted to accept or deny the incoming pairing request
   * @hide
   */
  static const int PAIRING_VARIANT_CONSENT = 3;

  /**
   * The user will be prompted to enter the passkey displayed on remote device
   * This is used for Bluetooth 2.1 pairing.
   * @hide
   */
  static const int PAIRING_VARIANT_DISPLAY_PASSKEY = 4;

  /**
   * The user will be prompted to enter the PIN displayed on remote device.
   * This is used for Bluetooth 2.0 pairing.
   * @hide
   */
  static const int PAIRING_VARIANT_DISPLAY_PIN = 5;

  /**
   * The user will be prompted to accept or deny the OOB pairing request
   * @hide
   */
  static const int PAIRING_VARIANT_OOB_CONSENT = 6;

  /**
   * Used as an extra field in {@link #ACTION_UUID} intents,
   * Contains the {@link android.os.ParcelUuid}s of the remote device which
   * is a parcelable version of {@link UUID}.
   */
  static const String EXTRA_UUID = "android.bluetooth.device.extra.UUID";
}
