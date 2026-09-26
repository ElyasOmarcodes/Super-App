package com.elyas.tamarkuz.ui.screens

import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AccessibilityNew
import androidx.compose.material.icons.rounded.AppBlocking
import androidx.compose.material.icons.rounded.BatteryChargingFull
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.NotificationsActive
import androidx.compose.material.icons.rounded.PhoneDisabled
import androidx.compose.material.icons.rounded.PhoneLocked
import androidx.compose.material.icons.rounded.Shield
import androidx.compose.material.icons.rounded.VerifiedUser
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.elyas.tamarkuz.data.AppState
import com.elyas.tamarkuz.service.SetupItem
import com.elyas.tamarkuz.service.SetupStatus
import com.elyas.tamarkuz.ui.components.HSpace
import com.elyas.tamarkuz.ui.components.IconBubble
import com.elyas.tamarkuz.ui.components.SectionTitle
import com.elyas.tamarkuz.ui.components.SoftCard
import com.elyas.tamarkuz.ui.components.SoftSwitch
import com.elyas.tamarkuz.ui.components.VSpace
import com.elyas.tamarkuz.ui.theme.Brand

@Composable
fun HomeScreen(
    state: AppState,
    setup: SetupStatus,
    onCallShield: (Boolean) -> Unit,
    onAppShield: (Boolean) -> Unit,
    onSetup: (SetupItem) -> Unit,
    contentPadding: PaddingValues = PaddingValues(),
) {
    LazyColumn(
        Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 18.dp, end = 18.dp,
            top = contentPadding.calculateTopPadding() + 12.dp,
            bottom = contentPadding.calculateBottomPadding() + 24.dp,
        ),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        item { Header() }
        item { Hero(state, setup) }
        item { Stats(state) }
        item { SectionTitle("ډالونه") }
        item {
            ShieldCard(
                icon = Icons.Rounded.PhoneLocked,
                tint = Brand.Violet,
                title = "د زنګونو ډال",
                subtitle = "یوازې د سپین لیست ${state.whitelist.size} شمېرې زنګ وهلای شي",
                checked = state.callShield,
                onChange = onCallShield,
            )
        }
        item {
            ShieldCard(
                icon = Icons.Rounded.AppBlocking,
                tint = Brand.Coral,
                title = "د ټولنیزو رسنیو ډال",
                subtitle = "${state.apps.count { it.enabled }} اپونه بند دي",
                checked = state.appShield,
                onChange = onAppShield,
            )
        }
        if (!setup.allDone) {
            item { SectionTitle("لومړنی تنظیم") }
            item { SetupCard(setup, onSetup) }
        }
    }
}

@Composable
private fun Header() {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(horizontal = 4.dp)) {
        Column(Modifier.weight(1f)) {
            Text("سلام 👋", style = MaterialTheme.typography.bodyLarge, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Text("تمرکز", style = MaterialTheme.typography.headlineLarge)
        }
        Box(
            Modifier.size(48.dp).clip(RoundedCornerShape(16.dp)).background(Brand.gradient),
            contentAlignment = Alignment.Center,
        ) {
            Icon(Icons.Rounded.Shield, contentDescription = null, tint = Color.White)
        }
    }
}

@Composable
private fun Hero(state: AppState, setup: SetupStatus) {
    val active = (state.callShield || state.appShield)
    Box(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(30.dp))
            .background(Brand.gradient)
    ) {
        Box(
            Modifier
                .align(Alignment.TopStart)
                .padding(start = 0.dp)
                .size(170.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.08f))
        )
        Column(Modifier.padding(22.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    Modifier.size(10.dp).clip(CircleShape)
                        .background(if (active) Color(0xFF7CFFB2) else Color(0xFFFFC2C8))
                )
                HSpace(8.dp)
                Text(
                    if (active) "ساتنه فعاله ده" else "ساتنه بنده ده",
                    color = Color.White.copy(alpha = 0.9f),
                    style = MaterialTheme.typography.labelLarge,
                )
            }
            VSpace(10.dp)
            Text(
                "ستاسو وخت، ستاسو اختیار",
                color = Color.White,
                style = MaterialTheme.typography.headlineSmall,
            )
            VSpace(4.dp)
            Text(
                "نه ناببره زنګونه، نه ټولنیزې رسنۍ — یوازې تاسو او ستاسو مطالعه.",
                color = Color.White.copy(alpha = 0.85f),
                style = MaterialTheme.typography.bodyMedium,
            )
            if (!setup.allDone) {
                VSpace(16.dp)
                Text(
                    "تنظیم: ${setup.doneCount} له ۵",
                    color = Color.White.copy(alpha = 0.9f),
                    style = MaterialTheme.typography.labelMedium,
                )
                VSpace(6.dp)
                LinearProgressIndicator(
                    progress = { setup.doneCount / 5f },
                    modifier = Modifier.fillMaxWidth().height(8.dp).clip(CircleShape),
                    color = Color.White,
                    trackColor = Color.White.copy(alpha = 0.25f),
                    strokeCap = StrokeCap.Round,
                    drawStopIndicator = {},
                )
            }
        }
    }
}

@Composable
private fun Stats(state: AppState) {
    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        StatTile(Modifier.weight(1f), Icons.Rounded.PhoneDisabled, Brand.Violet, state.blockedCalls.size.toString(), "بند زنګونه")
        StatTile(Modifier.weight(1f), Icons.Rounded.AppBlocking, Brand.Coral, state.blockedOpens.toString(), "مخنیول شوي")
        StatTile(Modifier.weight(1f), Icons.Rounded.VerifiedUser, Brand.Mint, state.whitelist.size.toString(), "سپین لیست")
    }
}

@Composable
private fun StatTile(modifier: Modifier, icon: ImageVector, tint: Color, value: String, label: String) {
    SoftCard(modifier, padding = 14.dp) {
        IconBubble(icon, tint, size = 38.dp)
        VSpace(10.dp)
        Text(value, style = MaterialTheme.typography.headlineSmall)
        Text(label, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun ShieldCard(
    icon: ImageVector,
    tint: Color,
    title: String,
    subtitle: String,
    checked: Boolean,
    onChange: (Boolean) -> Unit,
) {
    SoftCard(onClick = { onChange(!checked) }) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            IconBubble(icon, tint)
            HSpace(14.dp)
            Column(Modifier.weight(1f)) {
                Text(title, style = MaterialTheme.typography.titleMedium)
                Text(subtitle, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            HSpace(8.dp)
            SoftSwitch(checked, onChange)
        }
    }
}

private data class SetupRow(val item: SetupItem, val icon: ImageVector, val title: String, val hint: String, val done: Boolean)

@Composable
private fun SetupCard(setup: SetupStatus, onSetup: (SetupItem) -> Unit) {
    val rows = listOf(
        SetupRow(SetupItem.SCREENING_ROLE, Icons.Rounded.PhoneLocked, "د زنګ څارونکی", "دا اپ د زنګونو د څارنې اپ وټاکئ", setup.screeningRole),
        SetupRow(SetupItem.PHONE, Icons.Rounded.PhoneDisabled, "د تلیفون اجازې", "د اړیکو زنګونه هم بندولو لپاره", setup.phone),
        SetupRow(SetupItem.ACCESSIBILITY, Icons.Rounded.AccessibilityNew, "د لاسرسي خدمت", "د اپونو د بندولو لپاره اړین دی", setup.accessibility),
        SetupRow(SetupItem.NOTIFICATIONS, Icons.Rounded.NotificationsActive, "خبرتیاوې", "کله چې بند اپ نصب شي خبر شئ", setup.notifications),
        SetupRow(SetupItem.BATTERY, Icons.Rounded.BatteryChargingFull, "د بیټرۍ محدودیت", "څو ډال هیڅکله ودرول نه شي", setup.battery),
    )
    SoftCard(Modifier.animateContentSize()) {
        rows.forEachIndexed { i, row ->
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 6.dp)) {
                IconBubble(row.icon, if (row.done) Brand.Mint else MaterialTheme.colorScheme.primary, size = 40.dp)
                HSpace(12.dp)
                Column(Modifier.weight(1f)) {
                    Text(row.title, style = MaterialTheme.typography.titleSmall)
                    Text(row.hint, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                if (row.done) {
                    Icon(Icons.Rounded.CheckCircle, contentDescription = "فعال", tint = Brand.Mint)
                } else {
                    FilledTonalButton(onClick = { onSetup(row.item) }, contentPadding = PaddingValues(horizontal = 14.dp)) {
                        Text("فعال کړه")
                    }
                }
            }
            if (i == 2 && !row.done) {
                Text(
                    "که «محدود تنظیم» ولیدل شو: د اپ معلومات ← ⋮ ← «Allow restricted settings».",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.tertiary,
                    modifier = Modifier.padding(start = 52.dp, bottom = 4.dp),
                )
            }
        }
    }
}
