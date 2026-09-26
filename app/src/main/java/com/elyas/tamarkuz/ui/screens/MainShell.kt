package com.elyas.tamarkuz.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Apps
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.Settings
import androidx.compose.material.icons.rounded.VerifiedUser
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.elyas.tamarkuz.data.AppState
import com.elyas.tamarkuz.data.BlockMode
import com.elyas.tamarkuz.data.InstalledApp
import com.elyas.tamarkuz.data.WhitelistEntry
import com.elyas.tamarkuz.service.SetupItem
import com.elyas.tamarkuz.service.SetupStatus

enum class Tab(val label: String, val icon: ImageVector) {
    HOME("کور", Icons.Rounded.Home),
    WHITELIST("سپین لیست", Icons.Rounded.VerifiedUser),
    APPS("اپونه", Icons.Rounded.Apps),
    SETTINGS("تنظیمات", Icons.Rounded.Settings),
}

/** Every action the UI can ask for, so screens stay free of Android plumbing. */
interface ShellActions {
    fun selectTab(tab: Tab)
    fun setCallShield(on: Boolean)
    fun setAppShield(on: Boolean)
    fun setup(item: SetupItem)
    fun addNumber(name: String, number: String)
    fun removeNumber(entry: WhitelistEntry)
    fun pickContact()
    fun setAppEnabled(id: String, on: Boolean)
    fun setAppMode(id: String, mode: BlockMode)
    fun removeApp(id: String)
    fun loadInstalled(): List<InstalledApp>
    fun addApp(app: InstalledApp)
    fun setUnlockMinutes(min: Int)
    fun clearLog()
    fun lockNow()
}

@Composable
fun MainShell(
    tab: Tab,
    state: AppState,
    setup: SetupStatus,
    installed: Set<String>,
    codeLength: Int,
    actions: ShellActions,
) {
    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        bottomBar = {
            NavigationBar(containerColor = MaterialTheme.colorScheme.surface, tonalElevation = 0.dp) {
                Tab.entries.forEach { t ->
                    NavigationBarItem(
                        selected = t == tab,
                        onClick = { actions.selectTab(t) },
                        icon = { Icon(t.icon, contentDescription = null) },
                        label = { Text(t.label, style = MaterialTheme.typography.labelMedium) },
                        colors = NavigationBarItemDefaults.colors(
                            indicatorColor = MaterialTheme.colorScheme.primaryContainer,
                            selectedIconColor = MaterialTheme.colorScheme.primary,
                            selectedTextColor = MaterialTheme.colorScheme.primary,
                        ),
                    )
                }
            }
        },
    ) { padding ->
        AnimatedContent(
            targetState = tab,
            transitionSpec = {
                (fadeIn() + slideInVertically { it / 24 }) togetherWith fadeOut()
            },
            label = "tab",
            modifier = Modifier.fillMaxSize(),
        ) { current ->
            when (current) {
                Tab.HOME -> HomeScreen(
                    state = state,
                    setup = setup,
                    onCallShield = actions::setCallShield,
                    onAppShield = actions::setAppShield,
                    onSetup = actions::setup,
                    contentPadding = padding,
                )
                Tab.WHITELIST -> WhitelistScreen(
                    entries = state.whitelist,
                    onAdd = actions::addNumber,
                    onRemove = actions::removeNumber,
                    onPickContact = actions::pickContact,
                    contentPadding = padding,
                )
                Tab.APPS -> AppsScreen(
                    apps = state.apps,
                    installed = installed,
                    onEnabled = actions::setAppEnabled,
                    onMode = actions::setAppMode,
                    onRemove = actions::removeApp,
                    loadInstalled = actions::loadInstalled,
                    onAddApp = actions::addApp,
                    contentPadding = padding,
                )
                Tab.SETTINGS -> SettingsScreen(
                    state = state,
                    codeLength = codeLength,
                    onUnlockMinutes = actions::setUnlockMinutes,
                    onClearLog = actions::clearLog,
                    onLockNow = actions::lockNow,
                    contentPadding = padding,
                )
            }
        }
    }
}
