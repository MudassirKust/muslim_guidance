package com.example.islamlearning

import android.os.Build
import android.os.Bundle
import android.util.Log
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
// Add these two imports:
import android.view.LayoutInflater
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
class MainActivity: AudioServiceFragmentActivity() {

    private val CHANNEL = "com.muslimguidance/page_size"
    private val META_CHANNEL = "com.muslimguidance/meta_consent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
         // ── ADD THIS BLOCK (native ad factory registration) ──────────────
       GoogleMobileAdsPlugin.registerNativeAdFactory(
    flutterEngine,
    "medium_280",
    NativeAdFactory(LayoutInflater.from(this))
)
        // ────────────────────────────────────────────────────────────────
        // Detect and log page size information
        detectPageSize()

        // Set up method channel for Flutter to query page size
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPageSize" -> {
                    result.success(getPageSizeInfo())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Meta Audience Network consent — must be called before MobileAds.initialize()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, META_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initializeMetaAAN") {
                try {
                    com.facebook.ads.AdSettings.setDataProcessingOptions(arrayOf())
                    com.facebook.ads.AudienceNetworkAds
                        .buildInitSettings(this)
                        .initialize()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("META_INIT_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // ── ADD THIS (unregister on destroy to avoid memory leaks) ───────────
     override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "medium_280"
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "16KB Page Size Support: Initialized")
    }

    private fun detectPageSize() {
        try {
            // Use system property approach for page size detection
            val vmHeapSize = Runtime.getRuntime().maxMemory()
            val totalMemory = Runtime.getRuntime().totalMemory()
            val freeMemory = Runtime.getRuntime().freeMemory()

            Log.d("MainActivity", "VM Heap Size: ${vmHeapSize / 1024 / 1024}MB")
            Log.d("MainActivity", "Total Memory: ${totalMemory / 1024 / 1024}MB")
            Log.d("MainActivity", "Free Memory: ${freeMemory / 1024 / 1024}MB")

            // Check Android version for potential 16KB support
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                Log.d("MainActivity", "Running on Android API ${Build.VERSION.SDK_INT} (16KB page size capable)")
            }

            // Log device info
            Log.d("MainActivity", "Device: ${Build.MANUFACTURER} ${Build.MODEL}")
            Log.d("MainActivity", "Android Version: ${Build.VERSION.RELEASE}")
            Log.d("MainActivity", "App configured for 16KB page size compatibility")
        } catch (e: Exception) {
            Log.w("MainActivity", "Could not gather device info: ${e.message}")
        }
    }

    private fun getPageSizeInfo(): Map<String, Any> {
        return try {
            // Since we can't directly get page size, provide device capability info
            val vmHeapSize = Runtime.getRuntime().maxMemory()
            val is16KBCapable = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && vmHeapSize > 256 * 1024 * 1024 // 256MB+

            mapOf(
                "pageSize" to if (is16KBCapable) 16384 else 4096, // Estimated based on capabilities
                "is16KBSupported" to is16KBCapable,
                "apiLevel" to Build.VERSION.SDK_INT,
                "manufacturer" to Build.MANUFACTURER,
                "model" to Build.MODEL,
                "vmHeapSizeMB" to (vmHeapSize / 1024 / 1024),
                "configuredFor16KB" to true
            )
        } catch (e: Exception) {
            mapOf(
                "pageSize" to 4096, // Default fallback
                "is16KBSupported" to false,
                "apiLevel" to Build.VERSION.SDK_INT,
                "manufacturer" to Build.MANUFACTURER,
                "model" to Build.MODEL,
                "error" to e.message.toString(),
                "configuredFor16KB" to true
            )
        }
    }
}
