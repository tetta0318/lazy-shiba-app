package com.example.lazy_shiba_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

// 【これが解決の鍵！】架け橋となる「R」クラスの場所を明示的に教えます
import com.example.lazy_shiba_app.R 

class TaskWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            // R.layout.widget_task がエラーにならず読み込めるようになります
            val views = RemoteViews(context.packageName, R.layout.widget_task)

            val taskText = widgetData.getString("task_message", "課題はありません")

            // R.id.widget_task_text も同様です
            views.setTextViewText(R.id.widget_task_text, taskText)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}