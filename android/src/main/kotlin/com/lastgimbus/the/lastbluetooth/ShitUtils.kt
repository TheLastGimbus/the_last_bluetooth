package com.lastgimbus.the.lastbluetooth

import android.bluetooth.BluetoothDevice
import android.os.Bundle


@Target(AnnotationTarget.CLASS, AnnotationTarget.PROPERTY, AnnotationTarget.EXPRESSION, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.SOURCE)
annotation class Shit

// ##### Shitty extension functions section #####

// XDDDDD
// TODO: Move this to some btutils or smth
val BluetoothDevice.isConnected: Boolean
    get() = this.javaClass.getMethod("isConnected").invoke(this) as Boolean

fun Bundle.itemsToString(): String =
    this.keySet().joinToString(", ") { "$it: <${this.get(it)?.javaClass?.name}>${this.get(it)}" }
