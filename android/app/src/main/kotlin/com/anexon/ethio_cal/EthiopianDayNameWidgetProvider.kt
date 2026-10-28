package com.anexon.ethio_cal

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews

class EthiopianDayNameWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_PREFIX = "flutter_android_widgets_"
        const val ACTION_REFRESH = "com.anexon.ethio_cal.EthiopianDayNameWidgetProvider.ACTION_REFRESH"
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action
        if (action == ACTION_REFRESH ||
            action == Intent.ACTION_DATE_CHANGED ||
            action == Intent.ACTION_TIME_CHANGED ||
            action == Intent.ACTION_TIMEZONE_CHANGED) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, EthiopianDayNameWidgetProvider::class.java))
            onUpdate(context, mgr, ids)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putString("flutter.widget_${appWidgetId}_type", "day_name").apply()
            val views = RemoteViews(context.packageName, R.layout.widget_ethiopian_day_name)

            val bgColorStr = prefs.getString("flutter.widget_${appWidgetId}_bgColor", null)
                ?: prefs.getString("flutter.widget_default_bgColor", "#CC1E1E1E") ?: "#CC1E1E1E"

            val textColorStr = prefs.getString("flutter.widget_${appWidgetId}_textColor", null)
                ?: prefs.getString("flutter.widget_default_textColor", "#FFFFFF") ?: "#FFFFFF"

            val accentColorStr = prefs.getString("flutter.widget_${appWidgetId}_accentColor", null)
                ?: prefs.getString("flutter.widget_default_accentColor", "#D6A87A") ?: "#D6A87A"

            try {
                views.setInt(R.id.widget_container, "setBackgroundColor", Color.parseColor(bgColorStr))
            } catch (_: Exception) {}

            try {
                views.setTextColor(R.id.text_day_name, Color.parseColor(textColorStr))
                views.setTextColor(R.id.text_saint, Color.parseColor(accentColorStr))
            } catch (_: Exception) {}

            val etNow = EthiopianCalendarHelper.now()
            val dayName = prefs.getString("flutter.${KEY_PREFIX}ethiopian_day", null)
                ?.takeIf { it.isNotEmpty() } ?: etNow.dayOnly

            val enableOrthodox = prefs.getBoolean("flutter.enableOrthodoxFeatures", true)
            val showDayNames = prefs.getBoolean("flutter.showOrthodoxDayNamesInWidgets", false)

            val saint = if (enableOrthodox && showDayNames) {
                prefs.getString("flutter.${KEY_PREFIX}orthodox_saint", null)
                    ?.takeIf { it.isNotEmpty() } ?: EthiopianCalendarHelper.getSaint(etNow.month, etNow.day)
            } else {
                ""
            }

            views.setTextViewText(R.id.text_day_name, dayName)

            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minHeight = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) ?: 0
            val minWidth = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 0

            val isSmall = (minWidth in 1..100) || (minHeight in 1..90)

            if (isSmall) {
                // In 1x1, both day name and orthodox saint name fit cleanly
                views.setTextViewTextSize(R.id.text_day_name, TypedValue.COMPLEX_UNIT_SP, 22f)
                views.setTextViewTextSize(R.id.text_saint, TypedValue.COMPLEX_UNIT_SP, 11f)
            } else {
                views.setTextViewTextSize(R.id.text_day_name, TypedValue.COMPLEX_UNIT_SP, 28f)
                views.setTextViewTextSize(R.id.text_saint, TypedValue.COMPLEX_UNIT_SP, 13f)
            }

            if (enableOrthodox && showDayNames && saint.isNotEmpty()) {
                views.setViewVisibility(R.id.text_saint, View.VISIBLE)
                views.setTextViewText(R.id.text_saint, saint)
            } else {
                views.setViewVisibility(R.id.text_saint, View.GONE)
            }

            // Tap to open app
            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (_: Exception) {}
    }
}
