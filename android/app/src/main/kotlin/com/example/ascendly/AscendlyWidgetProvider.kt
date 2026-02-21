package com.example.ascendly

import android.app.PendingIntent

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AscendlyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.streak_widget).apply {
                val streakDays = widgetData.getString("streak_days", "0")
                val streakText = widgetData.getString("streak_text", "0d 0h")
                val lastUpdate = widgetData.getString("last_update", "--:--")

                setTextViewText(R.id.streak_days, streakDays)
                setTextViewText(R.id.streak_text, streakText)
                setTextViewText(R.id.last_update, "Updated: $lastUpdate")

                // PendingIntent to launch the app
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

