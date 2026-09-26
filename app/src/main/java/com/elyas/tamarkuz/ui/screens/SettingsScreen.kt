package com.elyas.tamarkuz.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.History
import androidx.compose.material.icons.rounded.Key
import androidx.compose.material.icons.rounded.Lock
import androidx.compose.material.icons.rounded.PhoneDisabled
import androidx.compose.material.icons.rounded.Timer
import androidx.compose.material3.Button
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import com.elyas.tamarkuz.data.AppState
import com.elyas.tamarkuz.data.BlockedCall
import com.elyas.tamarkuz.ui.components.HSpace
import com.elyas.tamarkuz.ui.components.IconBubble
import com.elyas.tamarkuz.ui.components.SectionTitle
import com.elyas.tamarkuz.ui.components.SoftCard
import com.elyas.tamarkuz.ui.components.VSpace
import com.elyas.tamarkuz.ui.theme.Brand
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun SettingsScreen(
    state: AppState,
    codeLength: Int,
    onUnlockMinutes: (Int) -> Unit,
    onClearLog: () -> Unit,
    onLockNow: () -> Unit,
    contentPadding: PaddingValues = PaddingValues(),
) {
    LazyColumn(
        Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 18.dp, end = 18.dp,
            top = contentPadding.calculateTopPadding() + 12.dp,
            bottom = contentPadding.calculateBottomPadding() + 24.dp,
        ),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        item { ScreenHeader("تنظیمات", "شخصي اپ — یوازې ستاسو لپاره.") }

        item {
            SoftCard {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconBubble(Icons.Rounded.Timer, Brand.Magenta)
                    HSpace(14.dp)
                    Column(Modifier.weight(1f)) {
                        Text("د خلاصون موده (دقیقې)", style = MaterialTheme.typography.titleSmall)
                        Text(
                            "کله چې د کوډ سره اپ خلاص کړئ، دومره دقیقې خلاص پاتې کیږي.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
                VSpace(12.dp)
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    listOf(5, 10, 15, 30).forEach { m ->
                        FilterChip(
                            selected = state.unlockMinutes == m,
                            onClick = { onUnlockMinutes(m) },
                            label = {
                                Text(
                                    "$m",
                                    maxLines = 1,
                                    style = MaterialTheme.typography.titleSmall,
                                    modifier = Modifier.fillMaxWidth(),
                                    textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                                )
                            },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(14.dp),
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
                            ),
                        )
                    }
                }
            }
        }

        item {
            SoftCard {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconBubble(Icons.Rounded.Key, Brand.Violet)
                    HSpace(14.dp)
                    Column(Modifier.weight(1f)) {
                        Text("ثابت کوډ", style = MaterialTheme.typography.titleSmall)
                        Text(
                            "$codeLength رقمي کوډ. د بدلولو لپاره په GitHub کې APP_PASSCODE سیکرټ بدل کړئ او نوی APK جوړ کړئ.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
                VSpace(14.dp)
                Button(
                    onClick = onLockNow,
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(18.dp),
                    contentPadding = PaddingValues(vertical = 14.dp),
                ) {
                    Icon(Icons.Rounded.Lock, contentDescription = null)
                    HSpace(8.dp)
                    Text("اوس قفل یې کړه")
                }
            }
        }

        item {
            SectionTitle("د بند شوو زنګونو تاریخچه") {
                if (state.blockedCalls.isNotEmpty()) {
                    TextButton(onClick = onClearLog) { Text("پاکول") }
                }
            }
        }

        if (state.blockedCalls.isEmpty()) {
            item {
                SoftCard {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        IconBubble(Icons.Rounded.History, Brand.Mint)
                        HSpace(14.dp)
                        Text("تر اوسه کوم زنګ نه دی بند شوی.", style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        } else {
            item {
                SoftCard(padding = 6.dp) {
                    state.blockedCalls.take(30).forEachIndexed { i, call ->
                        CallRow(call)
                        if (i < minOf(state.blockedCalls.size, 30) - 1) {
                            HorizontalDivider(
                                Modifier.padding(horizontal = 14.dp),
                                color = MaterialTheme.colorScheme.outlineVariant,
                            )
                        }
                    }
                }
            }
        }
    }
}

private val timeFormat = SimpleDateFormat("yyyy/MM/dd  HH:mm", Locale.US)

@Composable
private fun CallRow(call: BlockedCall) {
    Row(Modifier.fillMaxWidth().padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
        IconBubble(Icons.Rounded.PhoneDisabled, Brand.Coral, size = 36.dp)
        HSpace(12.dp)
        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
            Text(
                call.number.ifBlank { "پټه شمېره" },
                style = MaterialTheme.typography.titleSmall,
            )
        }
        Text(
            timeFormat.format(Date(call.time)),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.weight(1f),
            textAlign = androidx.compose.ui.text.style.TextAlign.End,
        )
    }
}
