package com.elyas.tamarkuz.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Block
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.SelfImprovement
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.elyas.tamarkuz.data.BlockMode
import com.elyas.tamarkuz.ui.components.CodeEntry
import com.elyas.tamarkuz.ui.components.GlassSurface
import com.elyas.tamarkuz.ui.components.GradientBackground
import com.elyas.tamarkuz.ui.components.VSpace

@Composable
private fun HaloIcon(icon: ImageVector) {
    Box(
        Modifier.size(96.dp).clip(CircleShape).background(Color.White.copy(alpha = 0.14f)),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            Modifier.size(70.dp).clip(CircleShape).background(Color.White.copy(alpha = 0.22f)),
            contentAlignment = Alignment.Center,
        ) {
            Icon(icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(36.dp))
        }
    }
}

/** The gate in front of the whole app. */
@Composable
fun LockScreen(codeLength: Int, onSubmit: (String) -> Boolean, initial: String = "") {
    GradientBackground(Modifier.fillMaxSize()) {
        Column(
            Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding().padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            HaloIcon(Icons.Rounded.SelfImprovement)
            VSpace(20.dp)
            Text("تمرکز", style = MaterialTheme.typography.headlineLarge, color = Color.White)
            VSpace(6.dp)
            Text(
                "ارام ذهن، ژوره مطالعه",
                style = MaterialTheme.typography.bodyLarge,
                color = Color.White.copy(alpha = 0.85f),
            )
            VSpace(34.dp)
            Text(
                "د ننوتلو کوډ ولیکئ",
                style = MaterialTheme.typography.titleSmall,
                color = Color.White.copy(alpha = 0.92f),
            )
            VSpace(16.dp)
            CodeEntry(length = codeLength, onDark = true, onComplete = onSubmit, initial = initial)
        }
    }
}

/** Shown over a blocked social app. */
@Composable
fun BlockScreen(
    appLabel: String,
    mode: BlockMode,
    unlockMinutes: Int,
    codeLength: Int,
    onHome: () -> Unit,
    onCode: (String) -> Boolean,
    startWithCode: Boolean = false,
) {
    var askCode by remember { mutableStateOf(startWithCode) }
    GradientBackground(Modifier.fillMaxSize()) {
        Column(
            Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding().padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            HaloIcon(if (mode == BlockMode.ABSOLUTE) Icons.Rounded.Block else Icons.Rounded.Lock)
            VSpace(20.dp)
            Text(
                "$appLabel بند دی",
                style = MaterialTheme.typography.headlineMedium,
                color = Color.White,
                textAlign = TextAlign.Center,
            )
            VSpace(10.dp)
            Text(
                if (mode == BlockMode.ABSOLUTE)
                    "دا د تمرکز وخت دی. دا اپ په بشپړه توګه بند شوی او نه خلاصېږي."
                else
                    "دا اپ یوازې د ځانګړي کوډ په لیکلو سره د $unlockMinutes دقیقو لپاره خلاصېږي.",
                style = MaterialTheme.typography.bodyLarge,
                color = Color.White.copy(alpha = 0.88f),
                textAlign = TextAlign.Center,
            )
            VSpace(22.dp)
            GlassSurface(Modifier.fillMaxWidth()) {
                Text(
                    "«هر لوی کار له یوې کوچنۍ شېبې تمرکز څخه پیلېږي.»",
                    modifier = Modifier.padding(18.dp),
                    style = MaterialTheme.typography.bodyMedium,
                    textAlign = TextAlign.Center,
                )
            }
            VSpace(26.dp)
            if (mode == BlockMode.CODE && askCode) {
                CodeEntry(length = codeLength, onDark = true, onComplete = onCode)
            } else {
                Button(
                    onClick = onHome,
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 12.dp),
                    shape = RoundedCornerShape(20.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color(0xFF7F52FF)),
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(vertical = 16.dp),
                ) { Text("بېرته مطالعې ته", style = MaterialTheme.typography.titleSmall) }
                if (mode == BlockMode.CODE) {
                    VSpace(8.dp)
                    TextButton(onClick = { askCode = true }) {
                        Text("کوډ لرم — خلاص یې کړه", color = Color.White)
                    }
                }
            }
        }
    }
}
