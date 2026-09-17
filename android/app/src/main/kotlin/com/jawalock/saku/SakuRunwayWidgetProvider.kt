package com.jawalock.saku

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SakuRunwayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.saku_runway_widget).apply {
                val targetTitle = widgetData.getString("runway_target_title", "Alokasi Belanja Harian") ?: "Alokasi Belanja Harian"
                val countdownBadge = widgetData.getString("runway_countdown_badge", "Atur Target") ?: "Atur Target"
                val dailyAmount = widgetData.getString("runway_daily_amount", "Rp 0") ?: "Rp 0"
                val totalBalance = widgetData.getString("runway_total_balance", "Saldo: Rp 0") ?: "Saldo: Rp 0"
                val adviceText = widgetData.getString(
                    "runway_advice_text",
                    "Atur target pemasukan di Saku untuk mengaktifkan perhitungan jatah harian."
                ) ?: "Atur target pemasukan di Saku untuk mengaktifkan perhitungan jatah harian."

                setTextViewText(R.id.runway_target_title, targetTitle)
                setTextViewText(R.id.runway_countdown_badge, countdownBadge)
                setTextViewText(R.id.runway_daily_amount, dailyAmount)
                setTextViewText(R.id.runway_total_balance, totalBalance)
                setTextViewText(R.id.runway_advice_text, adviceText)

                // Deep link intent to open Saku Runway / Wallets Page
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("saku://runway")
                )
                setOnClickPendingIntent(R.id.runway_widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
