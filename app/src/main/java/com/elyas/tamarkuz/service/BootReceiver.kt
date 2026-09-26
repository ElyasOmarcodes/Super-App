package com.elyas.tamarkuz.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.elyas.tamarkuz.data.Store

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Store.init(context)
                CallGuardService.sync(context)
            }
        }
    }
}
