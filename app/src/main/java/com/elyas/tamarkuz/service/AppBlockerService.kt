package com.elyas.tamarkuz.service

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.SystemClock
import android.view.accessibility.AccessibilityEvent
import androidx.core.content.ContextCompat
import com.elyas.tamarkuz.data.BlockMode
import com.elyas.tamarkuz.data.Store
import com.elyas.tamarkuz.ui.BlockActivity

/**
 * Watches which app comes to the foreground. Blocked apps are sent home and
 * covered by [BlockActivity], either for good or until the code is entered.
 */
class AppBlockerService : AccessibilityService() {

    private var lastPkg: String? = null
    private var lastBlockAt = 0L

    private val installReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.getBooleanExtra(Intent.EXTRA_REPLACING, false)) return
            val pkg = intent.data?.schemeSpecificPart ?: return
            val app = Store.state.value.appFor(pkg) ?: return
            Notifications.appInstalled(context, app.label)
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Store.init(applicationContext)
        val filter = IntentFilter(Intent.ACTION_PACKAGE_ADDED).apply { addDataScheme("package") }
        ContextCompat.registerReceiver(this, installReceiver, filter, ContextCompat.RECEIVER_EXPORTED)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return

        val state = Store.state.value
        if (!state.appShield) return
        val app = state.appFor(pkg) ?: return
        if (app.mode == BlockMode.CODE && Store.isTemporarilyUnlocked(app.id)) return

        val now = SystemClock.elapsedRealtime()
        if (pkg == lastPkg && now - lastBlockAt < 700) return
        lastPkg = pkg
        lastBlockAt = now

        performGlobalAction(GLOBAL_ACTION_HOME)
        Store.countBlockedOpen()
        startActivity(BlockActivity.intent(this, app.id, pkg))
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        runCatching { unregisterReceiver(installReceiver) }
        super.onDestroy()
    }
}
