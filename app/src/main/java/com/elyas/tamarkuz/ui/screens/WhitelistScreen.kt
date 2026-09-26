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
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Contacts
import androidx.compose.material.icons.rounded.DeleteOutline
import androidx.compose.material.icons.rounded.PersonAdd
import androidx.compose.material.icons.rounded.VerifiedUser
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import com.elyas.tamarkuz.data.WhitelistEntry
import com.elyas.tamarkuz.ui.components.HSpace
import com.elyas.tamarkuz.ui.components.IconBubble
import com.elyas.tamarkuz.ui.components.LetterAvatar
import com.elyas.tamarkuz.ui.components.SoftCard
import com.elyas.tamarkuz.ui.components.VSpace
import com.elyas.tamarkuz.ui.theme.Brand

private val avatarColors = listOf(Brand.Violet, Brand.Magenta, Brand.Coral, Brand.Mint)

@Composable
fun WhitelistScreen(
    entries: List<WhitelistEntry>,
    onAdd: (name: String, number: String) -> Unit,
    onRemove: (WhitelistEntry) -> Unit,
    onPickContact: () -> Unit,
    contentPadding: PaddingValues = PaddingValues(),
) {
    var showAdd by remember { mutableStateOf(false) }

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
            ScreenHeader("سپین لیست", "یوازې دا خلک تاسو ته زنګ وهلای شي. نور ټول زنګونه په چوپه خوله بندېږي.")
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Button(
                    onClick = { showAdd = true },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(18.dp),
                    contentPadding = PaddingValues(vertical = 14.dp),
                ) {
                    Icon(Icons.Rounded.PersonAdd, contentDescription = null)
                    HSpace(8.dp)
                    Text("شمېره زیاته کړه")
                }
                OutlinedButton(
                    onClick = onPickContact,
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(18.dp),
                    contentPadding = PaddingValues(vertical = 14.dp),
                ) {
                    Icon(Icons.Rounded.Contacts, contentDescription = null)
                    HSpace(8.dp)
                    Text("له اړیکو")
                }
            }
        }
        if (entries.isEmpty()) {
            item { EmptyWhitelist() }
        }
        items(entries, key = { it.number }) { entry ->
            val color = avatarColors[(entry.name.hashCode() and 0x7fffffff) % avatarColors.size]
            SoftCard(padding = 14.dp) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    LetterAvatar(entry.name.ifBlank { "#" }, color)
                    HSpace(14.dp)
                    Column(Modifier.weight(1f)) {
                        Text(entry.name.ifBlank { "بې نومه" }, style = MaterialTheme.typography.titleSmall)
                        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
                            Text(
                                entry.number,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                textAlign = TextAlign.End,
                                modifier = Modifier.fillMaxWidth(),
                            )
                        }
                    }
                    IconButton(onClick = { onRemove(entry) }) {
                        Icon(Icons.Rounded.DeleteOutline, contentDescription = "لرې کول", tint = MaterialTheme.colorScheme.tertiary)
                    }
                }
            }
        }
    }

    if (showAdd) {
        AddNumberDialog(
            onDismiss = { showAdd = false },
            onSave = { name, number ->
                onAdd(name, number)
                showAdd = false
            },
        )
    }
}

@Composable
fun ScreenHeader(title: String, subtitle: String) {
    Column(Modifier.padding(horizontal = 4.dp, vertical = 4.dp)) {
        Text(title, style = MaterialTheme.typography.headlineMedium)
        VSpace(4.dp)
        Text(subtitle, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun EmptyWhitelist() {
    SoftCard {
        Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
            IconBubble(Icons.Rounded.VerifiedUser, Brand.Violet, size = 64.dp)
            VSpace(12.dp)
            Text("لا کومه شمېره نه ده ثبت شوې", style = MaterialTheme.typography.titleSmall)
            VSpace(4.dp)
            Text(
                "تر هغه چې شمېره زیاته نه کړئ، هر زنګ بندېږي.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
        }
    }
}

@Composable
private fun AddNumberDialog(onDismiss: () -> Unit, onSave: (String, String) -> Unit) {
    var name by remember { mutableStateOf("") }
    var number by remember { mutableStateOf("") }
    val valid = number.count { it.isDigit() } >= 3
    AlertDialog(
        onDismissRequest = onDismiss,
        shape = RoundedCornerShape(28.dp),
        title = { Text("نوې شمېره") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = name, onValueChange = { name = it },
                    label = { Text("نوم") }, singleLine = true,
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.fillMaxWidth(),
                )
                OutlinedTextField(
                    value = number, onValueChange = { v -> number = v.filter { it.isDigit() || it in "+ -" } },
                    label = { Text("د تلیفون شمېره") }, singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        },
        confirmButton = {
            Button(onClick = { onSave(name, number) }, enabled = valid) { Text("ثبت") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("لغوه") } },
    )
}
