package com.lastgimbus.the.lastbluetooth

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** TheLastBluetoothPlugin */
class TheLastBluetoothPlugin : FlutterPlugin, MethodCallHandler, BroadcastReceiver(), EventChannel.StreamHandler {
    companion object {
        const val TAG = "TheLastBluetoothPlugin"
    }

    private val PLUGIN_NAMESPACE = "the_last_bluetooth"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var eventSink: EventChannel.EventSink    // TODO: Rename it if we will need more than 1 of these

    private var bluetoothAdapter: BluetoothAdapter? = null


    // ##### FlutterPlugin stuff #####
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "$PLUGIN_NAMESPACE/methods")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "devicesStream")
        eventChannel.setStreamHandler(this);

        val context: Context = flutterPluginBinding.applicationContext
        val bm = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?
        bluetoothAdapter = bm?.adapter
        if (bluetoothAdapter == null) return;

        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }
        ContextCompat.registerReceiver(context, this, filter, ContextCompat.RECEIVER_EXPORTED)
        Log.d(TAG, "LISTENING.......")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }


    // ##### MethodCallHandler stuff #####
    @SuppressLint("MissingPermission")
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "Method call: $call")
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


    // ##### BroadcastReceiver stuff #####
    // BroadcastReceiver (for BluetoothDevice.ACTION_ACL_CONNECTED and BluetoothDevice.ACTION_ACL_DISCONNECTED)
    @SuppressLint("MissingPermission")  // Let user decide which permission they want
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            BluetoothDevice.ACTION_ACL_CONNECTED, BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                Log.i(TAG, "Device changed: ${intent.extras?.itemsToString()}")
                val it = intent.extras?.get(BluetoothDevice.EXTRA_DEVICE) as BluetoothDevice?
                if (it == null) {
                    Log.wtf(TAG, "There is no bt device extra in ACL_DIS/CONNECTED intent D:")
                } else {
                    val alias = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) it.alias else null
                    eventSink.success(
                        // <HashMap<String, Any?>> -ing this has no effect - Flutter fucks up the types anyway
                        listOf(
                            hashMapOf(
                                "name" to it.name,
                                "alias" to alias,
                                "address" to it.address,
                                "isConnected" to it.isConnected
                            )
                        )
                    )
                }
            }

            else -> Log.wtf(TAG, "This receiver should not get this intent: $intent")
        }
    }

    // ##### EventSink stuff #####
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) = eventSink.endOfStream()
}

// ##### Shitty extension functions section #####

// XDDDDD
// TODO: Move this to some btutils or smth
private val BluetoothDevice.isConnected: Boolean
    get() = this.javaClass.getMethod("isConnected").invoke(this) as Boolean

private fun Bundle.itemsToString(): String =
    this.keySet().joinToString(", ") { "$it: <${this.get(it)?.javaClass?.name}>${this.get(it)}" }


