package com.anexon.ethio_cal

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Bridges Flutter MethodChannel calls to Android AppWidget broadcasts. */
object FlutterAndroidWidgetsChannel {

    private const val CHANNEL = "flutter_android_widgets"

    val widgetProviders = listOf<Class<*>>(
        EthiopianDateWidgetProvider::class.java,
        EthiopianDayNameWidgetProvider::class.java,
        EthiopianDayWidgetProvider::class.java,
        ProgressEthiopianWidgetProvider::class.java,
        ProgressGregorianWidgetProvider::class.java
    )

    fun configure(activity: Activity, flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateAll" -> {
                        updateAll(activity)
                        result.success(null)
                    }
                    "updateWidget" -> {
                        val className = call.argument<String>("widgetName")
                        if (className != null) {
                            updateWidget(activity, className)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENT", "widgetName is required", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    fun updateAll(context: Context) {
        for (provider in widgetProviders) {
            sendUpdate(context, provider)
        }
    }

    fun updateWidget(context: Context, className: String) {
        val provider = widgetProviders.find { it.simpleName == className }
        if (provider != null) sendUpdate(context, provider)
    }

    fun updateWidgetById(context: Context, appWidgetId: Int) {
        val mgr = AppWidgetManager.getInstance(context)
        val info = mgr.getAppWidgetInfo(appWidgetId) ?: return
        val providerClass = widgetProviders.find { it.name == info.provider.className } ?: return
        val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE).apply {
            component = ComponentName(context, providerClass)
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
        }
        context.sendBroadcast(intent)
    }

    private fun sendUpdate(context: Context, provider: Class<*>) {
        val mgr = AppWidgetManager.getInstance(context)
        val ids = mgr.getAppWidgetIds(ComponentName(context, provider))
        if (ids.isNotEmpty()) {
            val intent = Intent(AppWidgetManager.ACTION_APPWIDGET_UPDATE).apply {
                component = ComponentName(context, provider)
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            context.sendBroadcast(intent)
        }
    }
}
