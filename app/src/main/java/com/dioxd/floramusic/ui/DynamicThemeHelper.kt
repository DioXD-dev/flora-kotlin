package com.dioxd.floramusic.ui

import android.graphics.Bitmap
import android.graphics.Color
import androidx.palette.graphics.Palette

/**
 * Mengekstrak warna dominan dari cover art dan menghasilkan
 * set warna Material You (primary, container, surface, on-surface).
 */
object DynamicThemeHelper {

    data class DynamicColors(
        val primary: Int,          // Warna utama (aksen)
        val onPrimary: Int,        // Teks di atas primary
        val primaryContainer: Int, // Container — lebih terang
        val onPrimaryContainer: Int,
        val surface: Int,          // Background card/surface
        val onSurface: Int,        // Teks di atas surface
        val background: Int,       // Background halaman
    )

    // Warna fallback jika tidak ada cover art
    val fallback = DynamicColors(
        primary             = Color.parseColor("#E8A87C"),
        onPrimary           = Color.parseColor("#2a1500"),
        primaryContainer    = Color.parseColor("#4a2010"),
        onPrimaryContainer  = Color.parseColor("#FDEBD8"),
        surface             = Color.parseColor("#242019"),
        onSurface           = Color.parseColor("#F0EBE3"),
        background          = Color.parseColor("#1A1714"),
    )

    fun fromBitmap(bitmap: Bitmap): DynamicColors {
        val palette = Palette.from(bitmap).generate()

        // Ambil swatch terbaik — prioritas: Vibrant → Muted → DarkVibrant
        val swatch = palette.vibrantSwatch
            ?: palette.mutedSwatch
            ?: palette.darkVibrantSwatch
            ?: return fallback

        val primary = swatch.rgb
        val h = FloatArray(3)
        Color.colorToHSV(primary, h)

        // Buat turunan warna dari hue yang sama
        val primaryContainer = hsv(h[0], h[1] * 0.5f, 0.28f)
        val onPrimaryContainer = hsv(h[0], h[1] * 0.3f, 0.88f)
        val surface = hsv(h[0], h[1] * 0.25f, 0.14f)
        val background = hsv(h[0], h[1] * 0.20f, 0.09f)

        // onPrimary — hitam atau putih tergantung kecerahan primary
        val luminance = (0.299 * Color.red(primary) +
                         0.587 * Color.green(primary) +
                         0.114 * Color.blue(primary)) / 255.0
        val onPrimary = if (luminance > 0.45) Color.parseColor("#1a0e00")
                        else Color.parseColor("#FFFFFF")

        return DynamicColors(
            primary             = primary,
            onPrimary           = onPrimary,
            primaryContainer    = primaryContainer,
            onPrimaryContainer  = onPrimaryContainer,
            surface             = surface,
            onSurface           = Color.parseColor("#F0EBE3"),
            background          = background,
        )
    }

    private fun hsv(h: Float, s: Float, v: Float): Int {
        val arr = floatArrayOf(h, s.coerceIn(0f, 1f), v.coerceIn(0f, 1f))
        return Color.HSVToColor(arr)
    }
}
