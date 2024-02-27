package com.lastgimbus.the.lastbluetooth;

import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.annotation.Keep

@Keep
class TheLastUtils() {
    companion object {
        @JvmStatic
        fun isBluetoothDeviceConnected(device: BluetoothDevice): Boolean {
            return try {
                device.javaClass.getMethod("isConnected").invoke(device) as? Boolean? ?: false
            } catch (e: Throwable) {
                false
            }
        }

        @JvmStatic
        fun getIntentExtras(intent: Intent): Map<String, Any?> {
            val extras = intent.extras
            val map = mutableMapOf<String, Any?>()
            if (extras != null) {
                for (key in extras.keySet()) {
                    map[key] = extras.get(key)
                }
            }
            return map
        }
    }
}

interface BroadcastReceiverInterface {
    fun onReceive(context: Context, intent: Intent)
}

class TheLastBroadcastReceiver(private val receiverInterface: BroadcastReceiverInterface) : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = receiverInterface.onReceive(context, intent)
}
