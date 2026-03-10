package com.dioxd.floramusic.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val Accent     = Color(0xFFE8A87C)
private val Primary    = Color(0xFF4a9460)
private val BgLight    = Color(0xFFFFFDF9)
private val BgDark     = Color(0xFF1A1714)
private val SurfLight  = Color(0xFFF5F0EB)
private val SurfDark   = Color(0xFF242019)

private val LightColors = lightColorScheme(
    primary                = Primary,
    secondary              = Accent,
    secondaryContainer     = Color(0xFFFDEBD8),
    onSecondaryContainer   = Color(0xFF4a2010),
    surface                = BgLight,
    surfaceVariant         = SurfLight,
    onSurface              = Color(0xFF1a1a1a),
    onSurfaceVariant       = Color(0xFF666660),
    background             = BgLight,
)

private val DarkColors = darkColorScheme(
    primary                = Color(0xFF7EC8A0),
    secondary              = Accent,
    secondaryContainer     = Color(0xFF4a2010),
    onSecondaryContainer   = Color(0xFFFDEBD8),
    surface                = BgDark,
    surfaceVariant         = SurfDark,
    onSurface              = Color(0xFFF0EBE3),
    onSurfaceVariant       = Color(0xFF9A9490),
    background             = BgDark,
)

@Composable
fun FloraTheme(
    darkTheme: Boolean = androidx.compose.foundation.isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    MaterialTheme(
        colorScheme = if (darkTheme) DarkColors else LightColors,
        content     = content,
    )
}
