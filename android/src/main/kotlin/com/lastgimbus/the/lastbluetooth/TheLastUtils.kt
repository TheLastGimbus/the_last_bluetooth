package com.lastgimbus.the.lastbluetooth;

import android.bluetooth.BluetoothDevice

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
    }
}
