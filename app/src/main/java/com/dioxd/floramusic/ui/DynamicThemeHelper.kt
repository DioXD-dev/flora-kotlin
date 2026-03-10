package com.dioxd.floramusic.ui

import androidx.compose.ui.graphics.Color

/**
 * Menghasilkan warna placeholder yang konsisten berdasarkan judul lagu.
 * Dipakai sebagai background album art ketika cover tidak tersedia.
 */
object DynamicThemeHelper {

    private val palette = listOf(
        Color(0xFF4a9460), // hijau flora
        Color(0xFF7B6FA0), // ungu soft
        Color(0xFF5B8DB8), // biru
        Color(0xFFB06A4E), // coklat oranye
        Color(0xFF4E8B8B), // teal
        Color(0xFF9B6B9B), // lavender
        Color(0xFF7A9E5A), // sage
        Color(0xFFB07A50), // amber
        Color(0xFF5A7AB0), // slate blue
        Color(0xFF8B5E7A), // mauve
    )

    /** Warna konsisten berdasarkan hash judul */
    fun colorForTitle(title: String): Color {
        val idx = Math.abs(title.hashCode()) % palette.size
        return palette[idx].copy(alpha = 0.35f)
    }
}
