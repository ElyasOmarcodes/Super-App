package com.elyas.tamarkuz.security

import com.elyas.tamarkuz.BuildConfig
import java.security.MessageDigest

/** The fixed entry code. Only its salted hash is compiled into the app. */
object Passcode {
    val length: Int get() = BuildConfig.PASSCODE_LENGTH

    fun check(code: String): Boolean {
        val digest = MessageDigest.getInstance("SHA-256")
            .digest("tamarkuz:$code".toByteArray())
            .joinToString("") { "%02x".format(it) }
        return MessageDigest.isEqual(digest.toByteArray(), BuildConfig.PASSCODE_SHA256.toByteArray())
    }
}
