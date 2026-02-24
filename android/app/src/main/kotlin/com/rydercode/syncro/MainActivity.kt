package com.rydercode.syncro

import android.content.Context
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.syncro.app/multicast"
    private var multicastLock: WifiManager.MulticastLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquireMulticastLock" -> {
                    try {
                        acquireMulticastLock()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("MULTICAST_ERROR", e.message, null)
                    }
                }
                "releaseMulticastLock" -> {
                    try {
                        releaseMulticastLock()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("MULTICAST_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun acquireMulticastLock() {
        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        
        if (multicastLock == null) {
            multicastLock = wifiManager.createMulticastLock("syncro_multicast_lock")
            multicastLock?.setReferenceCounted(true)
        }
        
        if (multicastLock?.isHeld == false) {
            multicastLock?.acquire()
            android.util.Log.d("Syncro", "MulticastLock acquired")
        }
    }

    private fun releaseMulticastLock() {
        if (multicastLock?.isHeld == true) {
            multicastLock?.release()
            android.util.Log.d("Syncro", "MulticastLock released")
        }
    }

    override fun onDestroy() {
        releaseMulticastLock()
        super.onDestroy()
    }
}
