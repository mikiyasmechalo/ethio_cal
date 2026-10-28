package com.anexon.ethio_cal

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class WidgetConfigurationActivity : FlutterActivity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private val CHANNEL = "com.anexon.ethio_cal/widget_config"

    private fun extractAppWidgetId(): Int {
        if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
            return appWidgetId
        }
        val id = intent?.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (id != AppWidgetManager.INVALID_APPWIDGET_ID) {
            appWidgetId = id
        } else if (intent?.extras != null) {
            appWidgetId = intent.extras?.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        }
        return appWidgetId
    }

    private fun resolveWidgetType(id: Int): String {
        var type = ""
        if (id != AppWidgetManager.INVALID_APPWIDGET_ID) {
            val mgr = AppWidgetManager.getInstance(this)
            val info = mgr.getAppWidgetInfo(id)
            val providerClass = info?.provider?.className ?: ""
            type = when {
                providerClass.contains("EthiopianDayName") -> "day_name"
                providerClass.contains("EthiopianDay") -> "day"
                providerClass.contains("ProgressEthiopian") -> "progress_ethio"
                providerClass.contains("ProgressGregorian") -> "progress_greg"
                providerClass.contains("EthiopianDate") -> "date"
                else -> ""
            }
        }
        if (type.isEmpty() && id != AppWidgetManager.INVALID_APPWIDGET_ID) {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            type = prefs.getString("flutter.widget_${id}_type", "") ?: ""
        }
        if (type.isEmpty()) {
            type = "date"
        }
        return type
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Set the result to CANCELED. If the user backs out, the widget is not added.
        setResult(Activity.RESULT_CANCELED)
        extractAppWidgetId()
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
        extractAppWidgetId()
    }

    override fun getInitialRoute(): String {
        val id = extractAppWidgetId()
        val type = resolveWidgetType(id)
        return "/widget-config?appWidgetId=$id&widgetType=$type"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getWidgetInfo" -> {
                        val id = extractAppWidgetId()
                        val type = resolveWidgetType(id)
                        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                        val savedTheme = if (id != AppWidgetManager.INVALID_APPWIDGET_ID) {
                            prefs.getString("flutter.widget_${id}_theme", null)
                        } else null

                        val savedOpacity = if (id != AppWidgetManager.INVALID_APPWIDGET_ID) {
                            try {
                                val f = prefs.getFloat("flutter.widget_${id}_opacity", -1f)
                                if (f >= 0) f.toDouble() else null
                            } catch (_: Exception) {
                                null
                            }
                        } else null

                        result.success(mapOf(
                            "appWidgetId" to id,
                            "widgetType" to type,
                            "savedTheme" to savedTheme,
                            "savedOpacity" to savedOpacity
                        ))
                    }
                    "finishConfiguration" -> {
                        val id = call.argument<Int>("appWidgetId") ?: extractAppWidgetId()
                        
                        // Force immediate refresh of this widget
                        FlutterAndroidWidgetsChannel.updateWidgetById(this, id)

                        val resultValue = Intent().apply {
                            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
                        }
                        setResult(Activity.RESULT_OK, resultValue)
                        finish()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
