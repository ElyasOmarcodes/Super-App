package com.elyas.tamarkuz.service

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.elyas.tamarkuz.R
import com.elyas.tamarkuz.ui.MainActivity

object Notifications {
    const val CHANNEL_GUARD = "guard"
    const val CHANNEL_EVENTS = "events"
    const val ID_GUARD = 1

    fun createChannels(context: Context) {
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_GUARD, "د ساتنې خدمت", NotificationManager.IMPORTANCE_MIN).apply {
                setShowBadge(false)
            }
        )
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_EVENTS, "د بندیدو خبرتیاوې", NotificationManager.IMPORTANCE_DEFAULT)
        )
    }

    fun guard(context: Context): Notification =
        NotificationCompat.Builder(context, CHANNEL_GUARD)
            .setSmallIcon(R.drawable.ic_stat_shield)
            .setContentTitle("تمرکز فعال دی")
            .setContentText("یوازې سپین لیست زنګ وهلای شي")
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setContentIntent(openApp(context))
            .build()

    fun appInstalled(context: Context, label: String) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return
        val n = NotificationCompat.Builder(context, CHANNEL_EVENTS)
            .setSmallIcon(R.drawable.ic_stat_shield)
            .setContentTitle("$label نصب شو")
            .setContentText("دا اپ ستاسو د تمرکز لپاره له مخکې بند دی.")
            .setAutoCancel(true)
            .setContentIntent(openApp(context))
            .build()
        NotificationManagerCompat.from(context).notify(label.hashCode(), n)
    }

    private fun openApp(context: Context): PendingIntent = PendingIntent.getActivity(
        context, 0,
        Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )
}
