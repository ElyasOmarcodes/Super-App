package com.elyas.tamarkuz.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import com.elyas.tamarkuz.R

/** The Kotlin mark's own gradient: violet into magenta into coral. */
object Brand {
    val Violet = Color(0xFF7F52FF)
    val Magenta = Color(0xFFC811E2)
    val Coral = Color(0xFFE54857)
    val Mint = Color(0xFF2BB673)

    val gradient = Brush.linearGradient(listOf(Violet, Magenta, Coral))
    val softGradient = Brush.linearGradient(listOf(Color(0xFF9B7BFF), Color(0xFFD35BEA), Color(0xFFF07A85)))
}

private val Light = lightColorScheme(
    primary = Color(0xFF7F52FF),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFECE5FF),
    onPrimaryContainer = Color(0xFF2A0E77),
    secondary = Color(0xFFB02ACB),
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFFBE3FF),
    onSecondaryContainer = Color(0xFF3F0049),
    tertiary = Color(0xFFE54857),
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFFFFE2E4),
    onTertiaryContainer = Color(0xFF5B0612),
    background = Color(0xFFF7F5FC),
    onBackground = Color(0xFF1C1A23),
    surface = Color(0xFFFFFFFF),
    onSurface = Color(0xFF1C1A23),
    surfaceVariant = Color(0xFFF0ECF8),
    onSurfaceVariant = Color(0xFF6B6679),
    surfaceContainerLowest = Color(0xFFFFFFFF),
    surfaceContainerLow = Color(0xFFFBF9FF),
    surfaceContainer = Color(0xFFF3F0FA),
    surfaceContainerHigh = Color(0xFFEDE9F6),
    surfaceContainerHighest = Color(0xFFE7E2F2),
    outline = Color(0xFFCBC4DA),
    outlineVariant = Color(0xFFE6E1F0),
)

private val Dark = darkColorScheme(
    primary = Color(0xFFB9A3FF),
    onPrimary = Color(0xFF2A0E77),
    primaryContainer = Color(0xFF3B2A7A),
    onPrimaryContainer = Color(0xFFECE5FF),
    secondary = Color(0xFFF0A6FF),
    onSecondary = Color(0xFF3F0049),
    secondaryContainer = Color(0xFF5A1E68),
    onSecondaryContainer = Color(0xFFFBE3FF),
    tertiary = Color(0xFFFFB2B8),
    onTertiary = Color(0xFF5B0612),
    tertiaryContainer = Color(0xFF7A2430),
    onTertiaryContainer = Color(0xFFFFE2E4),
    background = Color(0xFF121018),
    onBackground = Color(0xFFE8E3F2),
    surface = Color(0xFF1B1824),
    onSurface = Color(0xFFE8E3F2),
    surfaceVariant = Color(0xFF2A2635),
    onSurfaceVariant = Color(0xFFB3ACC4),
    surfaceContainerLowest = Color(0xFF0E0C13),
    surfaceContainerLow = Color(0xFF191621),
    surfaceContainer = Color(0xFF1F1B29),
    surfaceContainerHigh = Color(0xFF282433),
    surfaceContainerHighest = Color(0xFF322D3E),
    outline = Color(0xFF4A4458),
    outlineVariant = Color(0xFF2F2A3A),
)

val Vazirmatn = FontFamily(
    Font(R.font.vazirmatn_regular, FontWeight.Normal),
    Font(R.font.vazirmatn_medium, FontWeight.Medium),
    Font(R.font.vazirmatn_bold, FontWeight.Bold),
    Font(R.font.vazirmatn_extrabold, FontWeight.ExtraBold),
)

private fun TextStyle.v() = copy(fontFamily = Vazirmatn)

private val base = Typography()
private val AppTypography = Typography(
    displayLarge = base.displayLarge.v(),
    displayMedium = base.displayMedium.v(),
    displaySmall = base.displaySmall.v(),
    headlineLarge = base.headlineLarge.v().copy(fontWeight = FontWeight.ExtraBold),
    headlineMedium = base.headlineMedium.v().copy(fontWeight = FontWeight.Bold),
    headlineSmall = base.headlineSmall.v().copy(fontWeight = FontWeight.Bold),
    titleLarge = base.titleLarge.v().copy(fontWeight = FontWeight.Bold),
    titleMedium = base.titleMedium.v().copy(fontWeight = FontWeight.Bold),
    titleSmall = base.titleSmall.v().copy(fontWeight = FontWeight.Medium),
    bodyLarge = base.bodyLarge.v(),
    bodyMedium = base.bodyMedium.v(),
    bodySmall = base.bodySmall.v(),
    labelLarge = base.labelLarge.v().copy(fontWeight = FontWeight.Bold),
    labelMedium = base.labelMedium.v().copy(fontWeight = FontWeight.Medium),
    labelSmall = base.labelSmall.v(),
)

private val AppShapes = Shapes(
    extraSmall = RoundedCornerShape(10.dp),
    small = RoundedCornerShape(14.dp),
    medium = RoundedCornerShape(20.dp),
    large = RoundedCornerShape(28.dp),
    extraLarge = RoundedCornerShape(36.dp),
)

@Composable
fun TamarkuzTheme(dark: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (dark) Dark else Light,
        typography = AppTypography,
        shapes = AppShapes,
    ) {
        // Pashto reads right to left whatever the phone's language.
        CompositionLocalProvider(LocalLayoutDirection provides LayoutDirection.Rtl, content = content)
    }
}
