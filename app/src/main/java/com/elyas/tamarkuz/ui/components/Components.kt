package com.elyas.tamarkuz.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.Backspace
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch

/** A white card with a whisper of shadow and a hairline border. */
@Composable
fun SoftCard(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
    padding: Dp = 18.dp,
    content: @Composable ColumnScope.() -> Unit,
) {
    val shape = RoundedCornerShape(26.dp)
    Column(
        modifier
            .fillMaxWidth()
            .shadow(10.dp, shape, ambientColor = Color(0x227F52FF), spotColor = Color(0x1A7F52FF))
            .clip(shape)
            .background(MaterialTheme.colorScheme.surface)
            .border(1.dp, MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.6f), shape)
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(padding),
        content = content,
    )
}

@Composable
fun IconBubble(icon: ImageVector, tint: Color, size: Dp = 46.dp) {
    Box(
        Modifier
            .size(size)
            .clip(RoundedCornerShape(size * 0.36f))
            .background(tint.copy(alpha = 0.14f)),
        contentAlignment = Alignment.Center,
    ) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(size * 0.52f))
    }
}

@Composable
fun LetterAvatar(label: String, color: Color, size: Dp = 46.dp) {
    Box(
        Modifier
            .size(size)
            .clip(RoundedCornerShape(size * 0.36f))
            .background(color.copy(alpha = 0.16f)),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label.firstOrNull()?.uppercase() ?: "?",
            color = color,
            fontWeight = FontWeight.ExtraBold,
            fontSize = (size.value * 0.42f).sp,
        )
    }
}

@Composable
fun SectionTitle(text: String, modifier: Modifier = Modifier, trailing: @Composable (() -> Unit)? = null) {
    Row(
        modifier.fillMaxWidth().padding(top = 8.dp, bottom = 4.dp, start = 4.dp, end = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(text, style = MaterialTheme.typography.titleMedium, modifier = Modifier.weight(1f))
        trailing?.invoke()
    }
}

@Composable
fun SoftSwitch(checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Switch(
        checked = checked,
        onCheckedChange = onCheckedChange,
        colors = SwitchDefaults.colors(
            checkedTrackColor = MaterialTheme.colorScheme.primary,
            uncheckedTrackColor = MaterialTheme.colorScheme.surfaceContainerHigh,
            uncheckedBorderColor = Color.Transparent,
            uncheckedThumbColor = MaterialTheme.colorScheme.outline,
        ),
    )
}

@Composable
fun Pill(text: String, color: Color, modifier: Modifier = Modifier) {
    Text(
        text,
        modifier = modifier
            .clip(CircleShape)
            .background(color.copy(alpha = 0.13f))
            .padding(horizontal = 10.dp, vertical = 3.dp),
        color = color,
        style = MaterialTheme.typography.labelMedium,
    )
}

/** Dots showing how many digits have been typed; shakes on a wrong code. */
@Composable
fun CodeDots(length: Int, filled: Int, error: Boolean, onDark: Boolean, shakeKey: Int) {
    val shake = remember { Animatable(0f) }
    LaunchedEffect(shakeKey) {
        if (shakeKey == 0) return@LaunchedEffect
        for (x in listOf(18f, -16f, 12f, -8f, 4f, 0f)) shake.animateTo(x, spring(stiffness = Spring.StiffnessHigh))
    }
    val on = if (onDark) Color.White else MaterialTheme.colorScheme.primary
    val off = if (onDark) Color.White.copy(alpha = 0.3f) else MaterialTheme.colorScheme.outline
    CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
        Row(
            Modifier.offset { IntOffset(shake.value.dp.roundToPx(), 0) },
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            repeat(length) { i ->
                val isOn = i < filled
                val size by animateDpAsState(if (isOn) 16.dp else 13.dp, label = "dot")
                val color by animateColorAsState(
                    when {
                        error -> Color(0xFFFF6B7A)
                        isOn -> on
                        else -> off
                    },
                    label = "dotColor",
                )
                Box(Modifier.size(18.dp), contentAlignment = Alignment.Center) {
                    Box(Modifier.size(size).clip(CircleShape).background(color))
                }
            }
        }
    }
}

/**
 * Round, pillowy number pad. Always laid out left to right, the way
 * phone keypads are, even inside the right-to-left UI.
 */
@Composable
fun Keypad(onDigit: (Char) -> Unit, onDelete: () -> Unit, onDark: Boolean, modifier: Modifier = Modifier) {
    val rows = listOf("123", "456", "789")
    CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Ltr) {
        Column(modifier, verticalArrangement = Arrangement.spacedBy(14.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            rows.forEach { r ->
                Row(horizontalArrangement = Arrangement.spacedBy(22.dp)) {
                    r.forEach { d -> KeyButton(onDark, onClick = { onDigit(d) }) { KeyLabel(d.toString(), onDark) } }
                }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(22.dp)) {
                Spacer(Modifier.size(74.dp))
                KeyButton(onDark, onClick = { onDigit('0') }) { KeyLabel("0", onDark) }
                KeyButton(onDark, filled = false, onClick = onDelete) {
                    Icon(
                        Icons.AutoMirrored.Rounded.Backspace, contentDescription = "پاکول",
                        tint = if (onDark) Color.White else MaterialTheme.colorScheme.onSurface,
                    )
                }
            }
        }
    }
}

@Composable
private fun KeyLabel(text: String, onDark: Boolean) {
    Text(
        text,
        fontSize = 28.sp,
        fontWeight = FontWeight.Medium,
        color = if (onDark) Color.White else MaterialTheme.colorScheme.onSurface,
    )
}

@Composable
private fun KeyButton(onDark: Boolean, filled: Boolean = true, onClick: () -> Unit, content: @Composable () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val pressed by interaction.collectIsPressedAsState()
    val scale by animateFloatAsState(if (pressed) 0.9f else 1f, spring(dampingRatio = 0.5f), label = "key")
    val bg = when {
        !filled -> Color.Transparent
        onDark -> Color.White.copy(alpha = if (pressed) 0.28f else 0.16f)
        else -> MaterialTheme.colorScheme.surfaceContainer
    }
    Box(
        Modifier
            .size(74.dp)
            .scale(scale)
            .clip(CircleShape)
            .background(bg)
            .clickable(interactionSource = interaction, indication = null, onClick = onClick),
        contentAlignment = Alignment.Center,
    ) { content() }
}

/** Holds typed digits and checks them once the code is complete. */
class CodeEntryState(val length: Int) {
    var code by mutableStateOf("")
    var error by mutableStateOf(false)
    var shakeKey by mutableIntStateOf(0)
}

@Composable
fun CodeEntry(
    length: Int,
    onDark: Boolean,
    onComplete: (String) -> Boolean,
    modifier: Modifier = Modifier,
    initial: String = "",
) {
    val state = remember { CodeEntryState(length).apply { code = initial } }
    val scope = rememberCoroutineScope()
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        CodeDots(length, state.code.length, state.error, onDark, state.shakeKey)
        Spacer(Modifier.height(10.dp))
        Box(Modifier.height(22.dp)) {
            if (state.error) {
                Text(
                    "کوډ سم نه دی، بیا هڅه وکړئ",
                    color = if (onDark) Color(0xFFFFD5DA) else MaterialTheme.colorScheme.tertiary,
                    style = MaterialTheme.typography.bodyMedium,
                )
            }
        }
        Spacer(Modifier.height(18.dp))
        Keypad(
            onDark = onDark,
            onDigit = { d ->
                if (state.code.length >= length) return@Keypad
                state.error = false
                state.code += d
                if (state.code.length == length) {
                    val ok = onComplete(state.code)
                    if (!ok) {
                        state.error = true
                        state.shakeKey++
                        scope.launch {
                            kotlinx.coroutines.delay(250)
                            state.code = ""
                        }
                    }
                }
            },
            onDelete = {
                state.error = false
                state.code = state.code.dropLast(1)
            },
        )
    }
}

@Composable
fun GradientBackground(modifier: Modifier = Modifier, content: @Composable () -> Unit) {
    Box(modifier.background(com.elyas.tamarkuz.ui.theme.Brand.gradient)) {
        // Two soft light blooms give the flat gradient some depth.
        Box(
            Modifier
                .offset(x = (-80).dp, y = (-60).dp)
                .size(280.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.10f))
        )
        Box(
            Modifier
                .align(Alignment.BottomEnd)
                .offset(x = 90.dp, y = 60.dp)
                .size(320.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.07f))
        )
        content()
    }
}

@Composable
fun GlassSurface(modifier: Modifier = Modifier, content: @Composable () -> Unit) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(24.dp),
        color = Color.White.copy(alpha = 0.16f),
        contentColor = Color.White,
    ) { content() }
}

@Composable
fun HSpace(w: Dp) = Spacer(Modifier.width(w))

@Composable
fun VSpace(h: Dp) = Spacer(Modifier.height(h))
