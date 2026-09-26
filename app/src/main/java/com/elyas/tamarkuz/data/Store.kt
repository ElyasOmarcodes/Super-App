package com.elyas.tamarkuz.data

import android.content.Context
import android.content.SharedPreferences
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.json.JSONArray
import org.json.JSONObject

/**
 * Single source of truth for the app, the call screener and the accessibility
 * service. Everything runs in one process, so a StateFlow over SharedPreferences
 * keeps them all in step.
 */
object Store {
    private const val FILE = "tamarkuz"
    private const val K_WHITELIST = "whitelist"
    private const val K_APPS = "apps"
    private const val K_CALL_SHIELD = "call_shield"
    private const val K_APP_SHIELD = "app_shield"
    private const val K_UNLOCK_MIN = "unlock_minutes"
    private const val K_CALLS = "blocked_calls"
    private const val K_OPENS = "blocked_opens"
    private const val K_UNLOCKED = "unlocked_until"
    private const val MAX_LOG = 100

    private var prefs: SharedPreferences? = null
    private val _state = MutableStateFlow(AppState(apps = SocialCatalog.defaults))
    val state: StateFlow<AppState> = _state.asStateFlow()

    @Synchronized
    fun init(context: Context) {
        if (prefs != null) return
        val p = context.applicationContext.getSharedPreferences(FILE, Context.MODE_PRIVATE)
        prefs = p
        _state.value = load(p)
    }

    // region mutations

    fun setCallShield(on: Boolean) = update { it.copy(callShield = on) }
    fun setAppShield(on: Boolean) = update { it.copy(appShield = on) }
    fun setUnlockMinutes(min: Int) = update { it.copy(unlockMinutes = min) }

    fun addToWhitelist(name: String, number: String) = update { s ->
        if (s.whitelist.any { PhoneNumbers.same(it.number, number) }) s
        else s.copy(whitelist = s.whitelist + WhitelistEntry(name.trim(), number.trim()))
    }

    fun removeFromWhitelist(entry: WhitelistEntry) = update { s ->
        s.copy(whitelist = s.whitelist - entry)
    }

    fun setAppEnabled(id: String, enabled: Boolean) = updateApp(id) { it.copy(enabled = enabled) }
    fun setAppMode(id: String, mode: BlockMode) = updateApp(id) { it.copy(mode = mode) }

    fun addCustomApp(app: InstalledApp) = update { s ->
        if (s.apps.any { app.pkg in it.packages }) s
        else s.copy(
            apps = s.apps + BlockedApp(
                id = BlockedApp.CUSTOM_PREFIX + app.pkg,
                label = app.label,
                packages = listOf(app.pkg),
                mode = BlockMode.ABSOLUTE,
                enabled = true,
                color = 0xFF7F52FF,
            )
        )
    }

    fun removeCustomApp(id: String) = update { s ->
        s.copy(apps = s.apps.filterNot { it.id == id && it.isCustom })
    }

    fun logBlockedCall(number: String) = update { s ->
        s.copy(blockedCalls = (listOf(BlockedCall(number, System.currentTimeMillis())) + s.blockedCalls).take(MAX_LOG))
    }

    fun clearCallLog() = update { it.copy(blockedCalls = emptyList()) }

    fun countBlockedOpen() = update { it.copy(blockedOpens = it.blockedOpens + 1) }

    fun unlockTemporarily(appId: String) = update { s ->
        val until = System.currentTimeMillis() + s.unlockMinutes * 60_000L
        s.copy(unlockedUntil = s.unlockedUntil.filterValues { it > System.currentTimeMillis() } + (appId to until))
    }

    fun isTemporarilyUnlocked(appId: String): Boolean =
        (_state.value.unlockedUntil[appId] ?: 0L) > System.currentTimeMillis()

    // endregion

    private fun updateApp(id: String, change: (BlockedApp) -> BlockedApp) = update { s ->
        s.copy(apps = s.apps.map { if (it.id == id) change(it) else it })
    }

    @Synchronized
    private fun update(change: (AppState) -> AppState) {
        val next = change(_state.value)
        if (next == _state.value) return
        _state.value = next
        prefs?.let { save(it, next) }
    }

    private fun load(p: SharedPreferences): AppState {
        val whitelist = p.getString(K_WHITELIST, null)?.let { json ->
            JSONArray(json).objects().map { WhitelistEntry(it.getString("name"), it.getString("number")) }
        } ?: emptyList()

        val saved = p.getString(K_APPS, null)?.let { json ->
            JSONArray(json).objects().map { o ->
                BlockedApp(
                    id = o.getString("id"),
                    label = o.getString("label"),
                    packages = o.getJSONArray("packages").strings(),
                    mode = runCatching { BlockMode.valueOf(o.getString("mode")) }.getOrDefault(BlockMode.ABSOLUTE),
                    enabled = o.optBoolean("enabled", true),
                    color = o.optLong("color", 0xFF7F52FF),
                )
            }
        } ?: emptyList()

        // Keep the user's choices, but let catalog updates add apps and packages.
        val byId = saved.associateBy { it.id }
        val apps = SocialCatalog.defaults.map { def ->
            byId[def.id]?.let { def.copy(mode = it.mode, enabled = it.enabled) } ?: def
        } + saved.filter { it.isCustom }

        val calls = p.getString(K_CALLS, null)?.let { json ->
            JSONArray(json).objects().map { BlockedCall(it.getString("number"), it.getLong("time")) }
        } ?: emptyList()

        val unlocked = p.getString(K_UNLOCKED, null)?.let { json ->
            val o = JSONObject(json)
            o.keys().asSequence().associateWith { o.getLong(it) }
        } ?: emptyMap()

        return AppState(
            whitelist = whitelist,
            callShield = p.getBoolean(K_CALL_SHIELD, true),
            appShield = p.getBoolean(K_APP_SHIELD, true),
            apps = apps,
            unlockMinutes = p.getInt(K_UNLOCK_MIN, 10),
            blockedCalls = calls,
            blockedOpens = p.getInt(K_OPENS, 0),
            unlockedUntil = unlocked,
        )
    }

    private fun save(p: SharedPreferences, s: AppState) {
        val whitelist = JSONArray().apply {
            s.whitelist.forEach { put(JSONObject().put("name", it.name).put("number", it.number)) }
        }
        val apps = JSONArray().apply {
            s.apps.forEach { a ->
                put(
                    JSONObject()
                        .put("id", a.id)
                        .put("label", a.label)
                        .put("packages", JSONArray(a.packages))
                        .put("mode", a.mode.name)
                        .put("enabled", a.enabled)
                        .put("color", a.color)
                )
            }
        }
        val calls = JSONArray().apply {
            s.blockedCalls.forEach { put(JSONObject().put("number", it.number).put("time", it.time)) }
        }
        val unlocked = JSONObject().apply { s.unlockedUntil.forEach { (k, v) -> put(k, v) } }

        p.edit()
            .putString(K_WHITELIST, whitelist.toString())
            .putString(K_APPS, apps.toString())
            .putBoolean(K_CALL_SHIELD, s.callShield)
            .putBoolean(K_APP_SHIELD, s.appShield)
            .putInt(K_UNLOCK_MIN, s.unlockMinutes)
            .putString(K_CALLS, calls.toString())
            .putInt(K_OPENS, s.blockedOpens)
            .putString(K_UNLOCKED, unlocked.toString())
            .apply()
    }

    private fun JSONArray.objects(): List<JSONObject> = (0 until length()).map { getJSONObject(it) }
    private fun JSONArray.strings(): List<String> = (0 until length()).map { getString(it) }
}
