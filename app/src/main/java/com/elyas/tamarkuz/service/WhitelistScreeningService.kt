package com.elyas.tamarkuz.service

import android.telecom.Call
import android.telecom.CallScreeningService
import com.elyas.tamarkuz.data.PhoneNumbers
import com.elyas.tamarkuz.data.Store

/**
 * Runs when this app holds the call-screening role. Every incoming call whose
 * number is not on the whitelist is rejected before the phone rings.
 *
 * Android does not send calls from saved contacts to a screening app, so
 * [CallGuardService] ends those as a second line of defence.
 */
class WhitelistScreeningService : CallScreeningService() {

    override fun onScreenCall(details: Call.Details) {
        Store.init(applicationContext)
        val state = Store.state.value
        val number = details.handle?.schemeSpecificPart
        val incoming = details.callDirection == Call.Details.DIRECTION_INCOMING
        val block = incoming && state.callShield && !PhoneNumbers.isAllowed(number, state.whitelist)

        val response = if (block) {
            CallResponse.Builder()
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipNotification(true)
                .setSkipCallLog(false)
                .build()
        } else {
            CallResponse.Builder().build()
        }
        respondToCall(details, response)
        if (block) Store.logBlockedCall(number.orEmpty())
    }
}
