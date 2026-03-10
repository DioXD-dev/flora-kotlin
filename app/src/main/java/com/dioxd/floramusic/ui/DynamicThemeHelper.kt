package com.dioxd.floramusic.ui

import androidx.compose.ui.graphics.Color

object DynamicThemeHelper {
    private val palette = listOf(
        Color(0xFF4a9460), Color(0xFF7B6FA0), Color(0xFF5B8DB8),
        Color(0xFFB06A4E), Color(0xFF4E8B8B), Color(0xFF9B6B9B),
        Color(0xFF7A9E5A), Color(0xFFB07A50), Color(0xFF5A7AB0),
        Color(0xFF8B5E7A),
    )
    fun colorForTitle(title: String): Color =
        palette[Math.abs(title.hashCode()) % palette.size].copy(alpha = 0.4f)
}
