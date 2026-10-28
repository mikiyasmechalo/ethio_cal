package com.anexon.ethio_cal

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.text.Html
import android.widget.RemoteViews

class ProgressGregorianWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_PREFIX = "flutter_android_widgets_"
        const val ACTION_REFRESH = "com.anexon.ethio_cal.ProgressGregorianWidgetProvider.ACTION_REFRESH"
        private const val DOT_CHAR = "\u2022"     // bullet character for each dot
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) updateAppWidget(context, appWidgetManager, id)
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
            val ids = mgr.getAppWidgetIds(ComponentName(context, ProgressGregorianWidgetProvider::class.java))
            onUpdate(context, mgr, ids)
        }
    }

    private data class DotRows(val top: CharSequence, val bottom: CharSequence)

    private fun getPositionsForWidth(widthDp: Int): Int {
        return when {
            widthDp >= 340 -> 42
            widthDp >= 240 -> 38
            widthDp >= 180 -> 28
            widthDp in 1..179 -> 20
            else -> 38 // Default for 4-wide widget
        }
    }

    private fun sanitizeHtmlColor(colorStr: String, fallback: String): String {
        val clean = colorStr.trim().removePrefix("#")
        return when (clean.length) {
            8 -> "#" + clean.substring(2) // Strip alpha channel AARRGGBB -> RRGGBB
            6 -> "#$clean"
            else -> fallback
        }
    }

    private fun renderDots(
        progress: Int,
        positions: Int,
        rawFilledColor: String,
        rawUnfilledColor: String
    ): DotRows {
        val totalDots = positions * 2
        val filledColor = sanitizeHtmlColor(rawFilledColor, "#FFFFFF")
        val unfilledColor = sanitizeHtmlColor(rawUnfilledColor, "#555555")
        val safeProgress = progress.coerceIn(0, 100)
        val filledCount = if (safeProgress == 100) totalDots else (safeProgress * totalDots) / 100

        val topHtml = StringBuilder()
        val bottomHtml = StringBuilder()

        for (i in 0 until positions) {
            val topFilled = (2 * i) < filledCount
            val topColor = if (topFilled) filledColor else unfilledColor
            topHtml.append("<font color='$topColor'>$DOT_CHAR</font>")

            val bottomFilled = (2 * i + 1) < filledCount
            val bottomColor = if (bottomFilled) filledColor else unfilledColor
            bottomHtml.append("<font color='$bottomColor'>$DOT_CHAR</font>")
        }

        val topText = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Html.fromHtml(topHtml.toString(), Html.FROM_HTML_MODE_LEGACY)
        } else {
            @Suppress("DEPRECATION") Html.fromHtml(topHtml.toString())
        }

        val bottomText = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Html.fromHtml(bottomHtml.toString(), Html.FROM_HTML_MODE_LEGACY)
        } else {
            @Suppress("DEPRECATION") Html.fromHtml(bottomHtml.toString())
        }

        return DotRows(top = topText, bottom = bottomText)
    }

    private fun parsePercentText(value: String): Int {
        val numeric = value.trim().removeSuffix("%").trim()
        return numeric.toFloatOrNull()?.toInt()?.coerceIn(0, 100) ?: 0
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString("flutter.widget_${appWidgetId}_type", "progress_greg").apply()
        val views = RemoteViews(context.packageName, R.layout.widget_progress_gregorian)

        val bgColorStr = prefs.getString("flutter.widget_${appWidgetId}_bgColor", null)
            ?: prefs.getString("flutter.widget_default_bgColor", "#CC1E1E1E") ?: "#CC1E1E1E"

        val textColorStr = prefs.getString("flutter.widget_${appWidgetId}_textColor", null)
            ?: prefs.getString("flutter.widget_default_textColor", "#FFFFFF") ?: "#FFFFFF"

        val filledColor = prefs.getString("flutter.widget_${appWidgetId}_dotFilled", null)
            ?: prefs.getString("flutter.widget_default_dotFilled", "#FFFFFF") ?: "#FFFFFF"

        val unfilledColor = prefs.getString("flutter.widget_${appWidgetId}_dotUnfilled", null)
            ?: prefs.getString("flutter.widget_default_dotUnfilled", "#555555") ?: "#555555"

        try {
            views.setInt(R.id.layout_0, "setBackgroundColor", Color.parseColor(bgColorStr))
            val textCol = Color.parseColor(textColorStr)
            views.setTextColor(R.id.text_day, textCol)
            views.setTextColor(R.id.text_day_percent, textCol)
            views.setTextColor(R.id.text_week, textCol)
            views.setTextColor(R.id.text_week_percent, textCol)
            views.setTextColor(R.id.text_month, textCol)
            views.setTextColor(R.id.text_month_percent, textCol)
            views.setTextColor(R.id.text_year, textCol)
            views.setTextColor(R.id.text_year_percent, textCol)
        } catch (_: Exception) {}

        fun getString(key: String, fallback: String = "") =
            prefs.getString("flutter.$KEY_PREFIX$key", fallback) ?: fallback

        val dayLabel = getString("greg_day_label", "DAY")
        val dayPercentText = getString("greg_day_percent", "0%")
        val weekPercentText = getString("greg_week_percent", "0%")
        val monthPercentText = getString("greg_month_percent", "0%")
        val yearPercentText = getString("greg_year_percent", "0%")

        val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
        val widthDp = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH) ?: 0
        val positions = getPositionsForWidth(widthDp)

        val dayDots = renderDots(parsePercentText(dayPercentText), positions, filledColor, unfilledColor)
        views.setTextViewText(R.id.text_day, dayLabel)
        views.setTextViewText(R.id.text_day_percent, dayPercentText)
        views.setTextViewText(R.id.dots_day_top, dayDots.top)
        views.setTextViewText(R.id.dots_day_bottom, dayDots.bottom)

        val weekDots = renderDots(parsePercentText(weekPercentText), positions, filledColor, unfilledColor)
        views.setTextViewText(R.id.text_week, getString("greg_week_label", "WEEK 1"))
        views.setTextViewText(R.id.text_week_percent, weekPercentText)
        views.setTextViewText(R.id.dots_week_top, weekDots.top)
        views.setTextViewText(R.id.dots_week_bottom, weekDots.bottom)

        val monthDots = renderDots(parsePercentText(monthPercentText), positions, filledColor, unfilledColor)
        views.setTextViewText(R.id.text_month, getString("greg_month_label", "MONTH"))
        views.setTextViewText(R.id.text_month_percent, monthPercentText)
        views.setTextViewText(R.id.dots_month_top, monthDots.top)
        views.setTextViewText(R.id.dots_month_bottom, monthDots.bottom)

        val yearDots = renderDots(parsePercentText(yearPercentText), positions, filledColor, unfilledColor)
        views.setTextViewText(R.id.text_year, getString("greg_year_label", "YEAR"))
        views.setTextViewText(R.id.text_year_percent, yearPercentText)
        views.setTextViewText(R.id.dots_year_top, yearDots.top)
        views.setTextViewText(R.id.dots_year_bottom, yearDots.bottom)

        // Tap to open app
        val launchIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.layout_0, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
