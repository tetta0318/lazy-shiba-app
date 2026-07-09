package com.example.lazy_shiba_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class GradeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_grade)

            val attendanceRate = widgetData.getString("widget_grade_attendance_rate", null)?.toIntOrNull()
            val overallScore = widgetData.getString("widget_grade_overall_score", null)?.toIntOrNull()

            views.setTextViewText(
                R.id.widget_grade_attendance_label,
                if (attendanceRate != null) "出席率  ${attendanceRate}%" else "出席率  --"
            )
            views.setProgressBar(R.id.widget_grade_attendance_bar, 100, attendanceRate ?: 0, false)

            views.setTextViewText(
                R.id.widget_grade_overall_label,
                if (overallScore != null) "全体の成績  ${overallScore}%" else "全体の成績  --"
            )
            views.setProgressBar(R.id.widget_grade_overall_bar, 100, overallScore ?: 0, false)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}