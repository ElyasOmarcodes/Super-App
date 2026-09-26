package com.elyas.tamarkuz.ui

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.ContactsContract
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContract
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.Crossfade
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.elyas.tamarkuz.data.BlockMode
import com.elyas.tamarkuz.data.InstalledApp
import com.elyas.tamarkuz.data.Store
import com.elyas.tamarkuz.data.WhitelistEntry
import com.elyas.tamarkuz.security.Passcode
import com.elyas.tamarkuz.service.CallGuardService
import com.elyas.tamarkuz.service.Permissions
import com.elyas.tamarkuz.service.SetupItem
import com.elyas.tamarkuz.service.SetupStatus
import com.elyas.tamarkuz.ui.screens.LockScreen
import com.elyas.tamarkuz.ui.screens.MainShell
import com.elyas.tamarkuz.ui.screens.ShellActions
import com.elyas.tamarkuz.ui.screens.Tab
import com.elyas.tamarkuz.ui.theme.TamarkuzTheme

class MainActivity : ComponentActivity(), ShellActions {

    private var unlocked by mutableStateOf(false)
    private var tab by mutableStateOf(Tab.HOME)
    private var setup by mutableStateOf(SetupStatus())
    private var installed by mutableStateOf(emptySet<String>())

    private val roleRequest = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { refresh() }
    private val permissionRequest = registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { refresh() }
    private val contactPick = registerForActivityResult(PickPhone()) { uri -> uri?.let(::addFromContact) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val state by Store.state.collectAsStateWithLifecycle()
            TamarkuzTheme {
                Crossfade(targetState = unlocked, label = "lock") { open ->
                    if (!open) {
                        LockScreen(codeLength = Passcode.length, onSubmit = { code ->
                            Passcode.check(code).also { if (it) unlocked = true }
                        })
                    } else {
                        MainShell(
                            tab = tab,
                            state = state,
                            setup = setup,
                            installed = installed,
                            codeLength = Passcode.length,
                            actions = this,
                        )
                    }
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        refresh()
    }

    override fun onStop() {
        super.onStop()
        // Leaving the app locks it again.
        if (!isChangingConfigurations) unlocked = false
    }

    private fun refresh() {
        setup = Permissions.status(this)
        installed = Permissions.installedPackages(this)
        CallGuardService.sync(this)
    }

    // region ShellActions

    override fun selectTab(tab: Tab) {
        this.tab = tab
    }

    override fun setCallShield(on: Boolean) {
        Store.setCallShield(on)
        CallGuardService.sync(this)
    }

    override fun setAppShield(on: Boolean) = Store.setAppShield(on)

    override fun setup(item: SetupItem) {
        when (item) {
            SetupItem.SCREENING_ROLE -> Permissions.screeningRoleIntent(this)
                ?.let { roleRequest.launch(it) }
                ?: toast("دا تلیفون د زنګ څارنې رول نه لري")
            SetupItem.PHONE -> permissionRequest.launch(Permissions.phone)
            SetupItem.ACCESSIBILITY -> safeStart(Permissions.accessibilitySettingsIntent())
            SetupItem.NOTIFICATIONS -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                permissionRequest.launch(arrayOf(Manifest.permission.POST_NOTIFICATIONS))
            }
            SetupItem.BATTERY -> safeStart(Permissions.batteryIntent(this))
        }
    }

    override fun addNumber(name: String, number: String) = Store.addToWhitelist(name, number)
    override fun removeNumber(entry: WhitelistEntry) = Store.removeFromWhitelist(entry)

    override fun pickContact() {
        try {
            contactPick.launch(Unit)
        } catch (_: ActivityNotFoundException) {
            toast("د اړیکو اپ ونه موندل شو")
        }
    }

    override fun setAppEnabled(id: String, on: Boolean) = Store.setAppEnabled(id, on)
    override fun setAppMode(id: String, mode: BlockMode) = Store.setAppMode(id, mode)
    override fun removeApp(id: String) = Store.removeCustomApp(id)
    override fun loadInstalled(): List<InstalledApp> = Permissions.launchableApps(this)
    override fun addApp(app: InstalledApp) = Store.addCustomApp(app)
    override fun setUnlockMinutes(min: Int) = Store.setUnlockMinutes(min)
    override fun clearLog() = Store.clearCallLog()

    override fun lockNow() {
        unlocked = false
        tab = Tab.HOME
    }

    // endregion

    private fun addFromContact(uri: Uri) {
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER,
        )
        runCatching {
            contentResolver.query(uri, projection, null, null, null)?.use { c ->
                if (c.moveToFirst()) {
                    val name = c.getString(0).orEmpty()
                    val number = c.getString(1).orEmpty()
                    if (number.isNotBlank()) {
                        Store.addToWhitelist(name, number)
                        toast("$name سپین لیست ته زیات شو")
                    }
                }
            }
        }
    }

    private fun safeStart(intent: Intent) {
        try {
            startActivity(intent)
        } catch (_: ActivityNotFoundException) {
            startActivity(Permissions.appDetailsIntent(this))
        }
    }

    private fun toast(text: String) = Toast.makeText(this, text, Toast.LENGTH_SHORT).show()

    /** Picks a single phone number; the picker grants read access to just that row. */
    private class PickPhone : ActivityResultContract<Unit, Uri?>() {
        override fun createIntent(context: Context, input: Unit) =
            Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)

        override fun parseResult(resultCode: Int, intent: Intent?): Uri? =
            if (resultCode == RESULT_OK) intent?.data else null
    }
}
