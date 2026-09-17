package com.jawalock.saku

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

class SakuWalletsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.saku_wallets_widget).apply {
                val totalBalance = widgetData.getString("total_balance", "Rp 0") ?: "Rp 0"
                val walletCount = widgetData.getString("wallet_count", "0 Wallet") ?: "0 Wallet"
                val walletsJson = widgetData.getString("wallets_json", "[]") ?: "[]"

                setTextViewText(R.id.widget_total_balance, totalBalance)
                setTextViewText(R.id.widget_wallet_count, walletCount)

                // Set up the intent for the RemoteViewsService that provides data to the ListView
                val serviceIntent = Intent(context, SakuWalletsWidgetService::class.java).apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                    data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
                }
                setRemoteAdapter(R.id.wallet_list_view, serviceIntent)
                setEmptyView(R.id.wallet_list_view, R.id.wallet_empty_view)

                // Deep link intent to open Saku Wallets Page when clicking header
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("saku://wallets")
                )
                setOnClickPendingIntent(R.id.wallets_widget_root, pendingIntent)

                // Template pending intent for list items
                setPendingIntentTemplate(R.id.wallet_list_view, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.wallet_list_view)
        }
    }
}

class SakuWalletsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return SakuWalletsRemoteViewsFactory(applicationContext)
    }
}

class SakuWalletsRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private val walletList = mutableListOf<JSONObject>()

    override fun onCreate() {
        loadData()
    }

    override fun onDataSetChanged() {
        loadData()
    }

    private fun loadData() {
        walletList.clear()
        val widgetData = HomeWidgetPlugin.getData(context)
        val walletsJsonStr = widgetData.getString("wallets_json", "[]") ?: "[]"
        try {
            val jsonArray = JSONArray(walletsJsonStr)
            for (i in 0 until jsonArray.length()) {
                walletList.add(jsonArray.getJSONObject(i))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        walletList.clear()
    }

    override fun getCount(): Int = walletList.size

    override fun getViewAt(position: Int): RemoteViews {
        if (position !in 0 until walletList.size) {
            return RemoteViews(context.packageName, R.layout.saku_wallet_item)
        }

        val wallet = walletList[position]
        val name = wallet.optString("name", "Wallet")
        val balance = wallet.optString("balance", "Rp 0")

        return RemoteViews(context.packageName, R.layout.saku_wallet_item).apply {
            setTextViewText(R.id.wallet_name, name)
            setTextViewText(R.id.wallet_balance, balance)

            // Fill-in intent to open Saku
            val fillInIntent = Intent().apply {
                data = Uri.parse("saku://wallet_detail?id=${wallet.optInt("id", 0)}")
            }
            setOnClickFillInIntent(R.id.wallet_item_container, fillInIntent)
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}
