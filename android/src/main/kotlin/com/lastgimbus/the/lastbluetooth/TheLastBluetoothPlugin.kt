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
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** TheLastBluetoothPlugin */
class TheLastBluetoothPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        const val TAG = "TheLastBluetoothPlugin"
    }

    private val PLUGIN_NAMESPACE = "the_last_bluetooth"

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var eventSink: EventChannel.EventSink? = null    // TODO: Rename it if we will need more than 1 of these

    private var bluetoothAdapter: BluetoothAdapter? = null

    private val broadcastReceiverPairedDevices = object : BroadcastReceiver() {
        @SuppressLint("InlinedApi")
        val listenedBluetoothBroadcasts = listOf(
            BluetoothDevice.ACTION_ACL_CONNECTED,
            BluetoothDevice.ACTION_ACL_DISCONNECTED,
            BluetoothDevice.ACTION_BOND_STATE_CHANGED,
            BluetoothDevice.ACTION_NAME_CHANGED,
            // TODO: Check if this doens't *require* check (eg crashes otherwise) - else, just leave it in the list
            BluetoothDevice.ACTION_ALIAS_CHANGED,
            // TODO: Actually include those two in the data?
            // BluetoothDevice.ACTION_UUID,
            // BluetoothDevice.ACTION_CLASS_CHANGED,
            // TODO: Listen and react to this (close connections)
            // BluetoothDevice.ACTION_ACL_DISCONNECT_REQUESTED,
        )
        val intentFilter = IntentFilter().apply { listenedBluetoothBroadcasts.forEach { addAction(it) } }

        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                in listenedBluetoothBroadcasts -> {
                    Log.v(TAG, "Device changed (${intent.action}): ${intent.extras?.itemsToString()}")
                    eventSink?.success(getPairedDevices())  // Just send list of all devices (not only one changed)
                }

                else -> Log.wtf(TAG, "This receiver should not get this intent: $intent")
            }
        }
    }


    @SuppressLint("MissingPermission")
    private fun getPairedDevices(): List<HashMap<String, Any?>> = bluetoothAdapter!!.bondedDevices.map {
        val alias = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) it.alias else null
        hashMapOf("name" to it.name, "alias" to alias, "address" to it.address, "isConnected" to it.isConnected)
    }

    // ##### FlutterPlugin stuff #####
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context: Context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "$PLUGIN_NAMESPACE/methods")
        channel.setMethodCallHandler(this)

        EventChannel(flutterPluginBinding.binaryMessenger, "devicesStream").apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    eventSink!!.success(getPairedDevices())
                    context.registerReceiver(
                        broadcastReceiverPairedDevices,
                        broadcastReceiverPairedDevices.intentFilter
                    )
                }

                override fun onCancel(arguments: Any?) {
                    context.unregisterReceiver(broadcastReceiverPairedDevices)
                    eventSink = null
                }
            })
        }

        val bm = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?
        bluetoothAdapter = bm?.adapter
        if (bluetoothAdapter == null) return;
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
            "getPairedDevices" -> result.success(getPairedDevices())
            else -> result.notImplemented()
        }
    }
}

// ##### Shitty extension functions section #####

// XDDDDD
// TODO: Move this to some btutils or smth
private val BluetoothDevice.isConnected: Boolean
    get() = this.javaClass.getMethod("isConnected").invoke(this) as Boolean

private fun Bundle.itemsToString(): String =
    this.keySet().joinToString(", ") { "$it: <${this.get(it)?.javaClass?.name}>${this.get(it)}" }


