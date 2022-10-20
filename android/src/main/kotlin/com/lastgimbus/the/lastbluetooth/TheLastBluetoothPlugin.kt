package com.lastgimbus.the.lastbluetooth

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** TheLastBluetoothPlugin */
class TheLastBluetoothPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private val PLUGIN_NAMESPACE = "the_last_bluetooth"


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "$PLUGIN_NAMESPACE/methods")
        channel.setMethodCallHandler(this)

        val context: Context = flutterPluginBinding.applicationContext
        val bm = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?
        bluetoothAdapter = bm?.adapter
    }

    private var bluetoothAdapter: BluetoothAdapter? = null

    @SuppressLint("MissingPermission")
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (bluetoothAdapter == null) {
            if (call.method == "isAvailable") result.success(false)
            else result.error("bluetooth_unavailable", "bluetooth is not available", null)
            return
        }
        when (call.method) {
            "isAvailable" -> result.success(true)
            "isEnabled" -> result.success(bluetoothAdapter!!.isEnabled)
            "getName" -> result.success(bluetoothAdapter!!.name)
            "getPairedDevices" -> result.success(
                bluetoothAdapter!!.bondedDevices.map {
                    val alias = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) it.alias else null
                    hashMapOf<String, Any?>(
                        "name" to it.name, "alias" to alias, "address" to it.address, "isConnected" to it.isConnected
                    )
                }.toList()
            )

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

// XDDDDD
// TODO: Move this to some btutils or smth
private val BluetoothDevice.isConnected: Boolean
    get() = this.javaClass.getMethod("isConnected").invoke(this) as Boolean

