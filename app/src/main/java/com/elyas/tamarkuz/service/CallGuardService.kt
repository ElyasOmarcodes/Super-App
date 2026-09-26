package com.elyas.tamarkuz.service

import android.Manifest
import android.annotation.SuppressLint
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import com.elyas.tamarkuz.data.PhoneNumbers
import com.elyas.tamarkuz.data.Store

/**
 * Keeps a phone-state listener alive and hangs up ringing calls from numbers
 * that are not whitelisted. It covers the calls the screening service never
 * sees, such as those from saved contacts.
 */
class CallGuardService : Service() {

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.getStringExtra(TelephonyManager.EXTRA_STATE) != TelephonyManager.EXTRA_STATE_RINGING) return
            // The broadcast arrives twice; only the copy with the number is useful.
            @Suppress("DEPRECATION")
            val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER) ?: return
            onRinging(number)
        }
    }

    override fun onCreate() {
        super.onCreate()
        Store.init(applicationContext)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else 0
        ServiceCompat.startForeground(this, Notifications.ID_GUARD, Notifications.guard(this), type)
        ContextCompat.registerReceiver(
            this, receiver,
            IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED),
            ContextCompat.RECEIVER_EXPORTED,
        )
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!Store.state.value.callShield) {
            stopSelf()
            return START_NOT_STICKY
        }
        return START_STICKY
    }

    override fun onDestroy() {
        runCatching { unregisterReceiver(receiver) }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    @SuppressLint("MissingPermission")
    private fun onRinging(number: String) {
        val state = Store.state.value
        if (!state.callShield || number.isBlank()) return
        if (PhoneNumbers.isAllowed(number, state.whitelist)) return
        if (checkSelfPermission(Manifest.permission.ANSWER_PHONE_CALLS) != PackageManager.PERMISSION_GRANTED) return
        val telecom = getSystemService(TelecomManager::class.java) ?: return
        @Suppress("DEPRECATION")
        val ended = runCatching { telecom.endCall() }.getOrDefault(false)
        if (ended) Store.logBlockedCall(number)
    }

    companion object {
        fun sync(context: Context) {
            val intent = Intent(context, CallGuardService::class.java)
            val wanted = Store.state.value.callShield &&
                ContextCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED
            if (wanted) {
                runCatching { ContextCompat.startForegroundService(context, intent) }
            } else {
                context.stopService(intent)
            }
        }
    }
}
