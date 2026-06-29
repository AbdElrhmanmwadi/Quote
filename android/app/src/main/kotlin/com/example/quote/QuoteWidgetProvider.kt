package com.example.quote

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// Renders the quote pushed from Dart (see WidgetService) onto the home screen.
/// Tapping the widget opens the app.
class QuoteWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.quote_widget).apply {
                val quote = widgetData.getString("widget_quote", null)
                    ?: "Open Quotes for daily inspiration"
                val author = widgetData.getString("widget_author", null) ?: ""
                setTextViewText(R.id.widget_quote, quote)
                setTextViewText(R.id.widget_author, author)

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
