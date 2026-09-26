package com.elyas.tamarkuz.ui

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.elyas.tamarkuz.data.BlockMode
import com.elyas.tamarkuz.data.Store
import com.elyas.tamarkuz.security.Passcode
import com.elyas.tamarkuz.ui.screens.BlockScreen
import com.elyas.tamarkuz.ui.theme.TamarkuzTheme

/** Covers a blocked app. Back and "home" both go to the launcher, never back into the app. */
class BlockActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() = goHome()
        })
        render(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        render(intent)
    }

    private fun render(intent: Intent) {
        Store.init(applicationContext)
        val appId = intent.getStringExtra(EXTRA_APP_ID)
        val pkg = intent.getStringExtra(EXTRA_PKG)
        val app = Store.state.value.apps.firstOrNull { it.id == appId }
        if (app == null || pkg == null) {
            finish()
            return
        }
        setContent {
            TamarkuzTheme {
                BlockScreen(
                    appLabel = app.label,
                    mode = app.mode,
                    unlockMinutes = Store.state.value.unlockMinutes,
                    codeLength = Passcode.length,
                    onHome = ::goHome,
                    onCode = { code ->
                        val ok = app.mode == BlockMode.CODE && Passcode.check(code)
                        if (ok) openUnlocked(app.id, pkg)
                        ok
                    },
                )
            }
        }
    }

    private fun openUnlocked(appId: String, pkg: String) {
        Store.unlockTemporarily(appId)
        Toast.makeText(this, "د ${Store.state.value.unlockMinutes} دقیقو لپاره خلاص شو", Toast.LENGTH_SHORT).show()
        packageManager.getLaunchIntentForPackage(pkg)?.let {
            startActivity(it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
        finish()
    }

    private fun goHome() {
        startActivity(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        )
        finish()
    }

    companion object {
        private const val EXTRA_APP_ID = "app_id"
        private const val EXTRA_PKG = "pkg"

        fun intent(context: Context, appId: String, pkg: String) =
            Intent(context, BlockActivity::class.java)
                .putExtra(EXTRA_APP_ID, appId)
                .putExtra(EXTRA_PKG, pkg)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
    }
}
