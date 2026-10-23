package com.anexon.ethio_cal

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews

/** Orthodox Calendar Widget Provider (Dark). */
class OrthodoxWidgetDarkProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_PREFIX = "flutter_android_widgets_"
        const val ACTION_REFRESH = "com.anexon.ethio_cal.OrthodoxWidgetDarkProvider.ACTION_REFRESH"
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_REFRESH -> {
                val mgr = AppWidgetManager.getInstance(context)
                val ids = mgr.getAppWidgetIds(ComponentName(context, OrthodoxWidgetDarkProvider::class.java))
                onUpdate(context, mgr, ids)
            }
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.widget_orthodox_dark_provider)

        views.setTextViewText(R.id.text_0, prefs.getString("flutter.${KEY_PREFIX}ethiopian_date", "") ?: "")
        views.setTextViewText(R.id.text_1, prefs.getString("flutter.${KEY_PREFIX}ethiopian_day", "") ?: "")
        views.setTextViewText(R.id.text_2, prefs.getString("flutter.${KEY_PREFIX}orthodox_saint", "") ?: "")
        views.setTextViewText(R.id.text_3, prefs.getString("flutter.${KEY_PREFIX}orthodox_year", "") ?: "")

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
