package mx.com.braincode.finiquitomx

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Puente mínimo con Android: preferencias, abrir enlaces y compartir texto. */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val prefs = getSharedPreferences("calculadora", Context.MODE_PRIVATE)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/native")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getPrefs" -> result.success(
                            prefs.all.filterValues { it is Boolean || it is String || it is Int }
                                + mapOf("appVersion" to appVersion())
                        )
                        "setBool" -> {
                            prefs.edit().putBoolean(call.argument<String>("key")!!,
                                call.argument<Boolean>("value")!!).apply()
                            result.success(null)
                        }
                        "setString" -> {
                            prefs.edit().putString(call.argument<String>("key")!!,
                                call.argument<String>("value")!!).apply()
                            result.success(null)
                        }
                        "openUrl" -> {
                            val ok = try {
                                startActivity(Intent(Intent.ACTION_VIEW,
                                    Uri.parse(call.argument<String>("url")!!))
                                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                                true
                            } catch (e: Exception) {
                                false
                            }
                            result.success(ok)
                        }
                        "share" -> {
                            val send = Intent(Intent.ACTION_SEND).apply {
                                type = "text/plain"
                                putExtra(Intent.EXTRA_TEXT, call.argument<String>("text")!!)
                            }
                            startActivity(Intent.createChooser(send, "Compartir"))
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("ERR", e.message, null)
                }
            }
    }

    private fun appVersion(): String = try {
        packageManager.getPackageInfo(packageName, 0).versionName ?: ""
    } catch (e: Exception) {
        ""
    }
}
