package com.example.lazy_shiba_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TaskWidgetProvider : HomeWidgetProvider() {
    private data class TaskRow(val rowId: Int, val nameId: Int, val remainingId: Int)

    private val rows = listOf(
        TaskRow(R.id.widget_task_row_1, R.id.widget_task_name_1, R.id.widget_task_remaining_1),
        TaskRow(R.id.widget_task_row_2, R.id.widget_task_name_2, R.id.widget_task_remaining_2),
        TaskRow(R.id.widget_task_row_3, R.id.widget_task_name_3, R.id.widget_task_remaining_3),
        TaskRow(R.id.widget_task_row_4, R.id.widget_task_name_4, R.id.widget_task_remaining_4)
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_task)

            rows.forEachIndexed { index, row ->
                val name = widgetData.getString("widget_task_name_${index + 1}", null)

                if (name.isNullOrEmpty()) {
                    views.setViewVisibility(row.rowId, View.GONE)
                } else {
                    val remaining = widgetData.getString("widget_task_remaining_${index + 1}", "")
                    views.setViewVisibility(row.rowId, View.VISIBLE)
                    views.setTextViewText(row.nameId, name)
                    views.setTextViewText(row.remainingId, remaining)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
