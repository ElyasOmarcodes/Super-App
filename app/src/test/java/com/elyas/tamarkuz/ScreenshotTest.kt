package com.elyas.tamarkuz

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.elyas.tamarkuz.data.AppState
import com.elyas.tamarkuz.data.BlockMode
import com.elyas.tamarkuz.data.BlockedCall
import com.elyas.tamarkuz.data.InstalledApp
import com.elyas.tamarkuz.data.PhoneNumbers
import com.elyas.tamarkuz.data.SocialCatalog
import com.elyas.tamarkuz.data.WhitelistEntry
import com.elyas.tamarkuz.service.SetupItem
import com.elyas.tamarkuz.service.SetupStatus
import com.elyas.tamarkuz.ui.screens.BlockScreen
import com.elyas.tamarkuz.ui.screens.LockScreen
import com.elyas.tamarkuz.ui.screens.MainShell
import com.elyas.tamarkuz.ui.screens.ShellActions
import com.elyas.tamarkuz.ui.screens.Tab
import com.elyas.tamarkuz.ui.theme.TamarkuzTheme
import com.github.takahirom.roborazzi.RobolectricDeviceQualifiers
import com.github.takahirom.roborazzi.captureRoboImage
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

@RunWith(RobolectricTestRunner::class)
@GraphicsMode(GraphicsMode.Mode.NATIVE)
@Config(sdk = [35], qualifiers = RobolectricDeviceQualifiers.Pixel7)
class ScreenshotTest {

    private val now = 1_790_000_000_000L

    private val sample = AppState(
        whitelist = listOf(
            WhitelistEntry("مور", "+93 70 123 4567"),
            WhitelistEntry("پلار", "0799 876 543"),
            WhitelistEntry("استاد احمد", "+93 78 555 1212"),
            WhitelistEntry("ورور", "0744 222 333"),
        ),
        callShield = true,
        appShield = true,
        apps = SocialCatalog.defaults.mapIndexed { i, a ->
            when (a.id) {
                "youtube" -> a.copy(mode = BlockMode.CODE)
                "telegram" -> a.copy(mode = BlockMode.CODE)
                else -> if (i > 14) a.copy(enabled = false) else a
            }
        },
        blockedCalls = listOf(
            BlockedCall("+93 72 000 1111", now - 3_600_000),
            BlockedCall("", now - 7_200_000),
            BlockedCall("0780 456 789", now - 86_400_000),
            BlockedCall("+971 50 123 4567", now - 2 * 86_400_000),
        ),
        blockedOpens = 37,
    )

    private val installed = setOf("com.whatsapp", "com.facebook.katana", "com.google.android.youtube", "org.telegram.messenger")

    private val noop = object : ShellActions {
        override fun selectTab(tab: Tab) = Unit
        override fun setCallShield(on: Boolean) = Unit
        override fun setAppShield(on: Boolean) = Unit
        override fun setup(item: SetupItem) = Unit
        override fun addNumber(name: String, number: String) = Unit
        override fun removeNumber(entry: WhitelistEntry) = Unit
        override fun pickContact() = Unit
        override fun setAppEnabled(id: String, on: Boolean) = Unit
        override fun setAppMode(id: String, mode: BlockMode) = Unit
        override fun removeApp(id: String) = Unit
        override fun loadInstalled(): List<InstalledApp> = emptyList()
        override fun addApp(app: InstalledApp) = Unit
        override fun setUnlockMinutes(min: Int) = Unit
        override fun clearLog() = Unit
        override fun lockNow() = Unit
    }

    private fun shot(name: String, dark: Boolean = false, content: @Composable () -> Unit) {
        captureRoboImage("screenshots/$name.png") {
            TamarkuzTheme(dark = dark) {
                Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) { content() }
            }
        }
    }

    private fun shell(tab: Tab, setup: SetupStatus = SetupStatus(true, true, false, true, false), dark: Boolean = false) =
        shot("0${tab.ordinal + 2}_${tab.name.lowercase()}${if (dark) "_dark" else ""}", dark) {
            MainShell(tab, sample, setup, installed, 4, noop)
        }

    @Test fun lock() = shot("01_lock") { LockScreen(codeLength = 4, onSubmit = { false }, initial = "12") }

    @Test fun home() = shell(Tab.HOME)

    @Test fun homeDark() = shell(Tab.HOME, SetupStatus(true, true, true, true, true), dark = true)

    @Test fun whitelist() = shell(Tab.WHITELIST)

    @Test fun apps() = shell(Tab.APPS)

    @Test fun settings() = shell(Tab.SETTINGS)

    @Test fun blockAbsolute() = shot("06_block_absolute") {
        BlockScreen("WhatsApp", BlockMode.ABSOLUTE, 10, 4, onHome = {}, onCode = { false })
    }

    @Test fun blockCode() = shot("07_block_code") {
        BlockScreen("YouTube", BlockMode.CODE, 10, 4, onHome = {}, onCode = { false }, startWithCode = true)
    }

    @Test fun numbersMatchAcrossFormats() {
        val list = listOf(WhitelistEntry("مور", "+93 70 123 4567"))
        assertTrue(PhoneNumbers.isAllowed("0701234567", list))
        assertTrue(PhoneNumbers.isAllowed("0093701234567", list))
        assertFalse(PhoneNumbers.isAllowed("0701234568", list))
        assertFalse(PhoneNumbers.isAllowed(null, list))
        assertFalse(PhoneNumbers.isAllowed("", list))
    }
}
