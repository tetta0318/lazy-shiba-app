package com.example.lazy_shiba_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ScheduleWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_schedule)

            views.setTextViewText(
                R.id.widget_schedule_tomorrow,
                widgetData.getString("widget_schedule_tomorrow", null) ?: "明日　－"
            )
            views.setTextViewText(
                R.id.widget_schedule_week,
                widgetData.getString("widget_schedule_week", null) ?: "1週間　－"
            )
            views.setTextViewText(
                R.id.widget_schedule_month,
                widgetData.getString("widget_schedule_month", null) ?: "1か月　－"
            )
            views.setTextViewText(
                R.id.widget_schedule_holiday,
                widgetData.getString("widget_schedule_holiday", null) ?: "一番近い休校日"
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}