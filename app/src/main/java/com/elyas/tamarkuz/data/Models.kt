package com.elyas.tamarkuz.data

enum class BlockMode { ABSOLUTE, CODE }

data class WhitelistEntry(val name: String, val number: String)

data class BlockedApp(
    val id: String,
    val label: String,
    val packages: List<String>,
    val mode: BlockMode,
    val enabled: Boolean,
    val color: Long,
) {
    val isCustom: Boolean get() = id.startsWith(CUSTOM_PREFIX)

    companion object {
        const val CUSTOM_PREFIX = "custom:"
    }
}

data class BlockedCall(val number: String, val time: Long)

data class AppState(
    val whitelist: List<WhitelistEntry> = emptyList(),
    val callShield: Boolean = true,
    val appShield: Boolean = true,
    val apps: List<BlockedApp> = emptyList(),
    val unlockMinutes: Int = 10,
    val blockedCalls: List<BlockedCall> = emptyList(),
    val blockedOpens: Int = 0,
    val unlockedUntil: Map<String, Long> = emptyMap(),
) {
    fun appFor(pkg: String): BlockedApp? = apps.firstOrNull { it.enabled && pkg in it.packages }
}

data class InstalledApp(val label: String, val pkg: String)
