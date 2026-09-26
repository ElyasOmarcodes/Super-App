@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.elyas.tamarkuz.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Add
import androidx.compose.material.icons.rounded.Block
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.Key
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.SegmentedButtonDefaults
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.elyas.tamarkuz.data.BlockMode
import com.elyas.tamarkuz.data.BlockedApp
import com.elyas.tamarkuz.data.InstalledApp
import com.elyas.tamarkuz.ui.components.HSpace
import com.elyas.tamarkuz.ui.components.LetterAvatar
import com.elyas.tamarkuz.ui.components.Pill
import com.elyas.tamarkuz.ui.components.SoftCard
import com.elyas.tamarkuz.ui.components.SoftSwitch
import com.elyas.tamarkuz.ui.components.VSpace
import com.elyas.tamarkuz.ui.theme.Brand

@Composable
fun AppsScreen(
    apps: List<BlockedApp>,
    installed: Set<String>,
    onEnabled: (String, Boolean) -> Unit,
    onMode: (String, BlockMode) -> Unit,
    onRemove: (String) -> Unit,
    loadInstalled: () -> List<InstalledApp>,
    onAddApp: (InstalledApp) -> Unit,
    contentPadding: PaddingValues = PaddingValues(),
) {
    var showPicker by remember { mutableStateOf(false) }
    // Installed apps first: those are the ones that matter today.
    val sorted = apps.sortedByDescending { a -> a.packages.any { it in installed } }

    LazyColumn(
        Modifier.fillMaxSize(),
        contentPadding = PaddingValues(
            start = 18.dp, end = 18.dp,
            top = contentPadding.calculateTopPadding() + 12.dp,
            bottom = contentPadding.calculateBottomPadding() + 24.dp,
        ),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        item {
            ScreenHeader(
                "بند اپونه",
                "دا اپونه که اوس نصب وي یا وروسته نصب شي، بند پاتې کیږي. هر اپ مطلق بند کړئ یا یې په کوډ پورې وتړئ.",
            )
        }
        item {
            OutlinedButton(
                onClick = { showPicker = true },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(18.dp),
                contentPadding = PaddingValues(vertical = 14.dp),
            ) {
                Icon(Icons.Rounded.Add, contentDescription = null)
                HSpace(8.dp)
                Text("بل اپ زیات کړه")
            }
        }
        items(sorted, key = { it.id }) { app ->
            AppCard(
                app = app,
                isInstalled = app.packages.any { it in installed },
                onEnabled = { onEnabled(app.id, it) },
                onMode = { onMode(app.id, it) },
                onRemove = { onRemove(app.id) },
            )
        }
    }

    if (showPicker) {
        AppPickerDialog(
            apps = remember { loadInstalled() }.filter { i -> apps.none { i.pkg in it.packages } },
            onDismiss = { showPicker = false },
            onPick = {
                onAddApp(it)
                showPicker = false
            },
        )
    }
}

@Composable
private fun AppCard(
    app: BlockedApp,
    isInstalled: Boolean,
    onEnabled: (Boolean) -> Unit,
    onMode: (BlockMode) -> Unit,
    onRemove: () -> Unit,
) {
    SoftCard(padding = 14.dp) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            LetterAvatar(app.label, Color(app.color))
            HSpace(14.dp)
            Column(Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(app.label, style = MaterialTheme.typography.titleSmall)
                    if (isInstalled) {
                        HSpace(8.dp)
                        Pill("نصب شوی", Brand.Coral)
                    }
                }
                Text(
                    app.packages.first(),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
            if (app.isCustom) {
                IconButton(onClick = onRemove) {
                    Icon(Icons.Rounded.DeleteOutline, contentDescription = "لرې کول", tint = MaterialTheme.colorScheme.tertiary)
                }
            }
            SoftSwitch(app.enabled, onEnabled)
        }
        if (app.enabled) {
            VSpace(12.dp)
            SingleChoiceSegmentedButtonRow(Modifier.fillMaxWidth()) {
                SegmentedButton(
                    selected = app.mode == BlockMode.ABSOLUTE,
                    onClick = { onMode(BlockMode.ABSOLUTE) },
                    shape = SegmentedButtonDefaults.itemShape(0, 2),
                    icon = { Icon(Icons.Rounded.Block, contentDescription = null, modifier = Modifier.padding(0.dp)) },
                ) { Text("مطلق بند") }
                SegmentedButton(
                    selected = app.mode == BlockMode.CODE,
                    onClick = { onMode(BlockMode.CODE) },
                    shape = SegmentedButtonDefaults.itemShape(1, 2),
                    icon = { Icon(Icons.Rounded.Key, contentDescription = null) },
                ) { Text("د کوډ سره") }
            }
        }
    }
}

@Composable
private fun AppPickerDialog(apps: List<InstalledApp>, onDismiss: () -> Unit, onPick: (InstalledApp) -> Unit) {
    var query by remember { mutableStateOf("") }
    val shown = apps.filter { query.isBlank() || it.label.contains(query, true) || it.pkg.contains(query, true) }
    AlertDialog(
        onDismissRequest = onDismiss,
        shape = RoundedCornerShape(28.dp),
        title = { Text("اپ غوره کړئ") },
        text = {
            Column {
                OutlinedTextField(
                    value = query, onValueChange = { query = it },
                    placeholder = { Text("لټون…") }, singleLine = true,
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.fillMaxWidth(),
                )
                VSpace(8.dp)
                LazyColumn(Modifier.heightIn(max = 380.dp)) {
                    items(shown, key = { it.pkg }) { app ->
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .clickable { onPick(app) }
                                .padding(vertical = 10.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            LetterAvatar(app.label, Brand.Violet, size = 38.dp)
                            HSpace(12.dp)
                            Column {
                                Text(app.label, style = MaterialTheme.typography.titleSmall)
                                Text(app.pkg, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                        }
                    }
                }
            }
        },
        confirmButton = { TextButton(onClick = onDismiss) { Text("بندول") } },
    )
}
