package cn.paybysecond.pay_by_second

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "cn.paybysecond/app_updates")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "appInfo" -> {
                        @Suppress("DEPRECATION")
                        val info = packageManager.getPackageInfo(packageName, 0)
                        @Suppress("DEPRECATION")
                        val code = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
                        result.success(mapOf("version" to (info.versionName ?: ""),
                            "build" to code.toString(), "abi" to Build.SUPPORTED_ABIS.firstOrNull().orEmpty()))
                    }
                    "openRelease" -> {
                        val uri = (call.arguments as? String)?.let { Uri.parse(it) }
                        if (uri == null || uri.scheme != "https" || uri.host != "github.com" ||
                            uri.userInfo != null || (uri.port != -1 && uri.port != 443) ||
                            uri.query != null || uri.fragment != null ||
                            uri.pathSegments.size < 3 || uri.pathSegments[2] != "releases") {
                            result.success(false)
                        } else {
                            try {
                                startActivity(Intent(Intent.ACTION_VIEW, uri).addCategory(Intent.CATEGORY_BROWSABLE))
                                result.success(true)
                            } catch (_: ActivityNotFoundException) {
                                result.success(false)
                            } catch (_: SecurityException) {
                                result.success(false)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
