package com.elyas.tamarkuz

import android.app.Application
import com.elyas.tamarkuz.data.Store
import com.elyas.tamarkuz.service.Notifications

class TamarkuzApp : Application() {
    override fun onCreate() {
        super.onCreate()
        Store.init(this)
        Notifications.createChannels(this)
    }
}
