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

class EthiopianDateWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_PREFIX = "flutter_android_widgets_"
        const val ACTION_REFRESH = "com.anexon.ethio_cal.EthiopianDateWidgetProvider.ACTION_REFRESH"
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
            val ids = mgr.getAppWidgetIds(ComponentName(context, EthiopianDateWidgetProvider::class.java))
            onUpdate(context, mgr, ids)
        }
    }

    private fun dpToPx(context: Context, dp: Int): Int {
        return (dp * context.resources.displayMetrics.density).toInt()
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().putString("flutter.widget_${appWidgetId}_type", "date").apply()
            val views = RemoteViews(context.packageName, R.layout.widget_ethiopian_date)

            val bgColorStr = prefs.getString("flutter.widget_${appWidgetId}_bgColor", null)
                ?: prefs.getString("flutter.widget_default_bgColor", "#CC1E1E1E") ?: "#CC1E1E1E"

            val textColorStr = prefs.getString("flutter.widget_${appWidgetId}_textColor", null)
                ?: prefs.getString("flutter.widget_default_textColor", "#FFFFFF") ?: "#FFFFFF"

            val subtextColorStr = prefs.getString("flutter.widget_${appWidgetId}_subtextColor", null)
                ?: prefs.getString("flutter.widget_default_subtextColor", "#B3B3B3") ?: "#B3B3B3"

            val accentColorStr = prefs.getString("flutter.widget_${appWidgetId}_accentColor", null)
                ?: prefs.getString("flutter.widget_default_accentColor", "#D6A87A") ?: "#D6A87A"

            try {
                views.setInt(R.id.widget_container, "setBackgroundColor", Color.parseColor(bgColorStr))
            } catch (_: Exception) {}

            try {
                views.setTextColor(R.id.text_date, Color.parseColor(textColorStr))
                views.setTextColor(R.id.text_day, Color.parseColor(subtextColorStr))
                views.setTextColor(R.id.text_saint, Color.parseColor(accentColorStr))
            } catch (_: Exception) {}

            val etNow = EthiopianCalendarHelper.now()
            val date = prefs.getString("flutter.${KEY_PREFIX}ethiopian_date", null)
                ?.takeIf { it.isNotEmpty() } ?: etNow.formattedDate
            val day = prefs.getString("flutter.${KEY_PREFIX}ethiopian_day", null)
                ?.takeIf { it.isNotEmpty() } ?: etNow.dayOnly

            val enableOrthodox = prefs.getBoolean("flutter.enableOrthodoxFeatures", true)
            val showDayNames = prefs.getBoolean("flutter.showOrthodoxDayNamesInWidgets", false)

            val saint = if (enableOrthodox && showDayNames) {
                prefs.getString("flutter.${KEY_PREFIX}orthodox_saint", null)
                    ?.takeIf { it.isNotEmpty() } ?: EthiopianCalendarHelper.getSaint(etNow.month, etNow.day)
            } else {
                ""
            }

            views.setTextViewText(R.id.text_date, date)
            views.setTextViewText(R.id.text_day, day)

            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minHeight = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT) ?: 0
            val minWidth = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 0

            val isHeight1 = minHeight in 1..95
            val is1x1 = (minWidth in 1..100) && (minHeight in 1..100)

            if (isHeight1 || is1x1) {
                // Height 1 or 1x1: scale down text to fit nicely, hide saint
                val dateSize = if (is1x1) 13f else 15f
                val daySize = if (is1x1) 10f else 11f
                views.setViewPadding(
                    R.id.widget_container,
                    dpToPx(context, 10),
                    dpToPx(context, 4),
                    dpToPx(context, 10),
                    dpToPx(context, 4)
                )
                views.setTextViewTextSize(R.id.text_date, TypedValue.COMPLEX_UNIT_SP, dateSize)
                views.setTextViewTextSize(R.id.text_day, TypedValue.COMPLEX_UNIT_SP, daySize)
                views.setViewVisibility(R.id.text_saint, View.GONE)
            } else {
                // Height >= 2: standard sizes with saint when enabled
                views.setViewPadding(
                    R.id.widget_container,
                    dpToPx(context, 14),
                    dpToPx(context, 10),
                    dpToPx(context, 14),
                    dpToPx(context, 10)
                )
                views.setTextViewTextSize(R.id.text_date, TypedValue.COMPLEX_UNIT_SP, 20f)
                views.setTextViewTextSize(R.id.text_day, TypedValue.COMPLEX_UNIT_SP, 13f)
                if (saint.isNotEmpty()) {
                    views.setViewVisibility(R.id.text_saint, View.VISIBLE)
                    views.setTextViewText(R.id.text_saint, saint)
                } else {
                    views.setViewVisibility(R.id.text_saint, View.GONE)
                }
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
