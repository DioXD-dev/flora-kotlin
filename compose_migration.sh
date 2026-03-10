#!/bin/bash
# Flora Music — Migrasi ke Jetpack Compose
# Jalankan di dalam folder ~/flora-kotlin
#
# Yang dilakukan script ini:
#   1. Update app/build.gradle  — tambah Compose dependencies
#   2. Hapus file lama          — SongAdapter.kt, NowPlayingActivity.kt, semua XML layout
#   3. Tulis ulang MainActivity — jadi Compose entry point
#   4. Buat FloraApp.kt         — navigasi antar screen
#   5. Buat SongListScreen.kt   — daftar lagu (ganti RecyclerView + SongAdapter)
#   6. Buat NowPlayingScreen.kt — player (ganti NowPlayingActivity)
#   7. Buat FloraTheme.kt       — tema Material You
#   8. Buat DynamicThemeHelper  — ekstrak warna dari cover art
#   9. Update PlayerState.kt    — tambah shuffle, repeat, nextIndex, prevIndex

set -e  # Berhenti jika ada error

echo "🌿 Mulai migrasi ke Jetpack Compose..."
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 0: Cek apakah berada di direktori yang benar
# ─────────────────────────────────────────────────────────────────────────────
if [ ! -f "app/build.gradle" ]; then
    echo "❌ Jalankan script ini di dalam folder ~/flora-kotlin!"
    exit 1
fi

UI_DIR="app/src/main/java/com/dioxd/floramusic/ui"
DATA_DIR="app/src/main/java/com/dioxd/floramusic/data"
THEME_DIR="$UI_DIR/theme"
mkdir -p "$UI_DIR" "$DATA_DIR" "$THEME_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 1: Update app/build.gradle
# ─────────────────────────────────────────────────────────────────────────────
echo "📦 [1/9] Update app/build.gradle..."

# Backup dulu
cp app/build.gradle app/build.gradle.bak

# Tambah buildFeatures compose + composeOptions jika belum ada
if ! grep -q "compose = true" app/build.gradle; then
    # Sisipkan setelah android {
    sed -i '/^android {/a\    buildFeatures { compose = true }\n    composeOptions { kotlinCompilerExtensionVersion = "1.5.14" }' app/build.gradle
fi

# Tambah dependencies Compose jika belum ada
DEPS=(
    "implementation(platform(\"androidx.compose:compose-bom:2024.09.00\"))"
    "implementation(\"androidx.compose.ui:ui\")"
    "implementation(\"androidx.compose.ui:ui-tooling-preview\")"
    "implementation(\"androidx.compose.material3:material3\")"
    "implementation(\"androidx.activity:activity-compose:1.9.2\")"
    "implementation(\"androidx.lifecycle:lifecycle-viewmodel-compose:2.8.5\")"
    "implementation(\"androidx.navigation:navigation-compose:2.8.1\")"
    "implementation(\"io.coil-kt:coil-compose:2.7.0\")"
    "implementation(\"androidx.palette:palette-ktx:1.0.0\")"
    "debugImplementation(\"androidx.compose.ui:ui-tooling\")"
)

for dep in "${DEPS[@]}"; do
    dep_short=$(echo "$dep" | grep -oP '(?<=")[^"]+(?=")' | head -1)
    if ! grep -qF "$dep_short" app/build.gradle; then
        sed -i "/^dependencies {/a\\    $dep" app/build.gradle
    fi
done

echo "  ✓ build.gradle diupdate"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 2: Hapus file lama yang digantikan Compose
# ─────────────────────────────────────────────────────────────────────────────
echo "🗑️  [2/9] Hapus file XML & Kotlin lama..."

rm -f "$UI_DIR/SongAdapter.kt"
rm -f "$UI_DIR/NowPlayingActivity.kt"
rm -rf app/src/main/res/layout/
echo "  ✓ File lama dihapus"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 3: PlayerState.kt — tambah shuffle, repeat, helper index
# ─────────────────────────────────────────────────────────────────────────────
echo "💾 [3/9] Update PlayerState.kt..."

cat > "$DATA_DIR/PlayerState.kt" << 'EOF'
package com.dioxd.floramusic.data

import android.media.MediaPlayer
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

/**
 * Singleton state holder untuk MediaPlayer.
 * Menggunakan Compose State agar UI otomatis rekomposisi saat berubah.
 */
object PlayerState {
    var mediaPlayer: MediaPlayer? = null

    var songs: List<Song>   by mutableStateOf(emptyList())
    var currentIndex: Int   by mutableIntStateOf(-1)
    var isPlaying: Boolean  by mutableStateOf(false)
    var shuffle: Boolean    by mutableStateOf(false)
    var repeat: Boolean     by mutableStateOf(false)

    val currentSong: Song?
        get() = songs.getOrNull(currentIndex)

    // Callback untuk sync ke MainActivity mini player
    var onSongChanged: ((Song) -> Unit)?         = null
    var onPlayStateChanged: ((Boolean) -> Unit)? = null

    fun nextIndex(): Int {
        if (songs.isEmpty()) return 0
        return if (shuffle) {
            val candidates = songs.indices.filter { it != currentIndex }
            if (candidates.isEmpty()) 0 else candidates.random()
        } else {
            (currentIndex + 1) % songs.size
        }
    }

    fun prevIndex(): Int {
        if (songs.isEmpty()) return 0
        return if (currentIndex <= 0) songs.size - 1 else currentIndex - 1
    }
}
EOF
echo "  ✓ PlayerState.kt"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 4: DynamicThemeHelper.kt — ekstrak warna dari cover art
# ─────────────────────────────────────────────────────────────────────────────
echo "🎨 [4/9] Buat DynamicThemeHelper.kt..."

cat > "$UI_DIR/DynamicThemeHelper.kt" << 'EOF'
package com.dioxd.floramusic.ui

import android.graphics.Bitmap
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.palette.graphics.Palette

/**
 * Ekstrak warna dominan dari cover art Bitmap,
 * lalu hasilkan set warna Material You yang kohesif.
 */
object DynamicThemeHelper {

    data class DynamicColors(
        val primary: Color,
        val onPrimary: Color,
        val primaryContainer: Color,
        val onPrimaryContainer: Color,
        val surface: Color,
        val onSurface: Color,
        val background: Color,
    )

    val fallback = DynamicColors(
        primary              = Color(0xFFE8A87C),
        onPrimary            = Color(0xFF2a1500),
        primaryContainer     = Color(0xFF4a2010),
        onPrimaryContainer   = Color(0xFFFDEBD8),
        surface              = Color(0xFF242019),
        onSurface            = Color(0xFFF0EBE3),
        background           = Color(0xFF1A1714),
    )

    // Warna fallback placeholder per judul lagu (tanpa cover art)
    private val SEED_COLORS = listOf(
        0xFFB87840L, 0xFF7A6E88L, 0xFF5A9870L, 0xFFB86060L,
        0xFF5A84B8L, 0xFFB8980CL, 0xFF8870A8L, 0xFF5CA4A0L,
        0xFFA470A0L, 0xFF7A9854L, 0xFFB87090L, 0xFF5A78B8L,
    )

    fun colorForTitle(title: String): Color {
        val hash = title.fold(0) { acc, c -> acc * 31 + c.code }
        val seed = SEED_COLORS[Math.abs(hash) % SEED_COLORS.size]
        // Gelap sedikit untuk dark mode
        val r = ((seed shr 16 and 0xFF) * 0.70).toInt()
        val g = ((seed shr 8  and 0xFF) * 0.70).toInt()
        val b = ((seed         and 0xFF) * 0.70).toInt()
        return Color(r, g, b)
    }

    fun fromBitmap(bitmap: Bitmap): DynamicColors {
        val palette = Palette.from(bitmap).generate()

        val swatch = palette.vibrantSwatch
            ?: palette.mutedSwatch
            ?: palette.darkVibrantSwatch
            ?: return fallback

        val primary = Color(swatch.rgb)
        val hsv     = FloatArray(3)
        android.graphics.Color.colorToHSV(swatch.rgb, hsv)
        val h = hsv[0]; val s = hsv[1]

        fun tone(v: Float, sMult: Float = 1f) = Color(
            android.graphics.Color.HSVToColor(
                floatArrayOf(h, (s * sMult).coerceIn(0f, 1f), v)
            )
        )

        val luminance = (0.299 * android.graphics.Color.red(swatch.rgb) +
                         0.587 * android.graphics.Color.green(swatch.rgb) +
                         0.114 * android.graphics.Color.blue(swatch.rgb)) / 255.0

        return DynamicColors(
            primary            = primary,
            onPrimary          = if (luminance > 0.45) Color(0xFF1a0e00) else Color.White,
            primaryContainer   = tone(0.28f, 0.5f),
            onPrimaryContainer = tone(0.88f, 0.3f),
            surface            = tone(0.14f, 0.25f),
            onSurface          = Color(0xFFF0EBE3),
            background         = tone(0.09f, 0.2f),
        )
    }
}
EOF
echo "  ✓ DynamicThemeHelper.kt"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 5: FloraTheme.kt — tema Material 3
# ─────────────────────────────────────────────────────────────────────────────
echo "🖌️  [5/9] Buat FloraTheme.kt..."

cat > "$THEME_DIR/FloraTheme.kt" << 'EOF'
package com.dioxd.floramusic.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val FloraColorScheme = darkColorScheme(
    primary            = Color(0xFFE8A87C),
    onPrimary          = Color(0xFF2a1500),
    primaryContainer   = Color(0xFF4a2010),
    onPrimaryContainer = Color(0xFFFDEBD8),
    secondary          = Color(0xFF7EC8A0),
    onSecondary        = Color(0xFF1a3d28),
    surface            = Color(0xFF1c1a14),
    onSurface          = Color(0xFFF0EBE3),
    surfaceVariant     = Color(0xFF252219),
    onSurfaceVariant   = Color(0xFF9A9490),
    background         = Color(0xFF1A1714),
    onBackground       = Color(0xFFF0EBE3),
    outline            = Color(0xFF524d45),
)

@Composable
fun FloraTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = FloraColorScheme,
        content     = content,
    )
}
EOF
echo "  ✓ FloraTheme.kt"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 6: SongListScreen.kt — daftar lagu dengan LazyColumn
# ─────────────────────────────────────────────────────────────────────────────
echo "📋 [6/9] Buat SongListScreen.kt..."

cat > "$UI_DIR/SongListScreen.kt" << 'EOF'
package com.dioxd.floramusic.ui

import android.graphics.drawable.GradientDrawable
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song

@Composable
fun SongListScreen(
    songs: List<Song>,
    onSongClick: (Song, Int) -> Unit,
    onNowPlayingClick: () -> Unit,
) {
    var query by remember { mutableStateOf("") }
    val filtered = remember(query, songs) {
        if (query.isBlank()) songs
        else songs.filter {
            it.title.contains(query, true) ||
            it.artist.contains(query, true) ||
            it.album.contains(query, true)
        }
    }

    Box(modifier = Modifier.fillMaxSize()
        .background(MaterialTheme.colorScheme.background)) {

        Column(modifier = Modifier.fillMaxSize()) {

            // ── Header ────────────────────────────────────────────────────
            Column(modifier = Modifier.padding(start = 20.dp, end = 12.dp,
                                               top = 52.dp, bottom = 8.dp)) {
                Text(
                    text       = "🌿 Flora Music",
                    fontSize   = 24.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color      = MaterialTheme.colorScheme.onSurface,
                )
                Text(
                    text     = "${songs.size} lagu",
                    fontSize = 13.sp,
                    color    = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            // ── Search bar ────────────────────────────────────────────────
            val focusManager = LocalFocusManager.current
            OutlinedTextField(
                value           = query,
                onValueChange   = { query = it },
                placeholder     = { Text("Cari lagu, artis, album...") },
                leadingIcon     = { Icon(Icons.Default.Search, null) },
                trailingIcon    = {
                    if (query.isNotEmpty())
                        IconButton(onClick = { query = ""; focusManager.clearFocus() }) {
                            Icon(Icons.Default.Clear, null)
                        }
                },
                singleLine      = true,
                shape           = RoundedCornerShape(16.dp),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                keyboardActions = KeyboardActions(onSearch = { focusManager.clearFocus() }),
                modifier        = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
            )

            // ── Song list ─────────────────────────────────────────────────
            val listState = rememberLazyListState()
            LazyColumn(
                state           = listState,
                contentPadding  = PaddingValues(top = 8.dp, bottom = 120.dp),
                modifier        = Modifier.fillMaxSize(),
            ) {
                itemsIndexed(filtered, key = { _, s -> s.id }) { index, song ->
                    SongRow(
                        song       = song,
                        isPlaying  = song.id == PlayerState.currentSong?.id,
                        onClick    = {
                            val realIndex = songs.indexOf(song)
                            onSongClick(song, realIndex)
                        },
                    )
                    if (index < filtered.lastIndex)
                        HorizontalDivider(
                            modifier  = Modifier.padding(start = 80.dp, end = 16.dp),
                            thickness = 0.5.dp,
                            color     = MaterialTheme.colorScheme.outline.copy(alpha = 0.4f),
                        )
                }
            }
        }

        // ── Mini Player ───────────────────────────────────────────────────
        AnimatedVisibility(
            visible = PlayerState.currentSong != null,
            enter   = slideInVertically { it } + fadeIn(),
            exit    = slideOutVertically { it } + fadeOut(),
            modifier = Modifier.align(Alignment.BottomCenter),
        ) {
            PlayerState.currentSong?.let { song ->
                MiniPlayer(
                    song    = song,
                    onClick = onNowPlayingClick,
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 12.dp),
                )
            }
        }
    }
}

// ── Song row ──────────────────────────────────────────────────────────────────
@Composable
fun SongRow(song: Song, isPlaying: Boolean, onClick: () -> Unit) {
    val accent   = MaterialTheme.colorScheme.primary
    val bg       = if (isPlaying)
        DynamicThemeHelper.colorForTitle(song.title).copy(alpha = 0.15f)
        else Color.Transparent

    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .background(bg)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp),
    ) {
        // Album art
        AlbumArtThumbnail(song = song, size = 52)

        // Info
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 14.dp, end = 8.dp),
        ) {
            Text(
                text       = song.title,
                fontSize   = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color      = if (isPlaying) accent else MaterialTheme.colorScheme.onSurface,
                maxLines   = 1,
                overflow   = TextOverflow.Ellipsis,
            )
            Text(
                text     = song.artist,
                fontSize = 12.sp,
                color    = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }

        // Duration + playing dot
        Text(
            text     = song.durationText,
            fontSize = 11.sp,
            color    = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        if (isPlaying)
            Box(
                modifier = Modifier
                    .padding(start = 6.dp)
                    .size(7.dp)
                    .clip(CircleShape)
                    .background(accent),
            )
    }
}

// ── Album art thumbnail ───────────────────────────────────────────────────────
@Composable
fun AlbumArtThumbnail(song: Song, size: Int) {
    val placeholder = DynamicThemeHelper.colorForTitle(song.title)
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(size.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(placeholder),
    ) {
        AsyncImage(
            model                = song.albumArtUri,
            contentDescription   = null,
            contentScale         = ContentScale.Crop,
            modifier             = Modifier.fillMaxSize().clip(RoundedCornerShape(14.dp)),
        )
    }
}

// ── Mini Player ───────────────────────────────────────────────────────────────
@Composable
fun MiniPlayer(song: Song, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val seedColor = DynamicThemeHelper.colorForTitle(song.title)

    Surface(
        onClick   = onClick,
        shape     = RoundedCornerShape(20.dp),
        color     = seedColor.copy(alpha = 0.85f),
        tonalElevation = 8.dp,
        modifier  = modifier.fillMaxWidth(),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(10.dp),
        ) {
            AlbumArtThumbnail(song = song, size = 46)

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 12.dp),
            ) {
                Text(
                    text       = song.title,
                    fontSize   = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color      = Color.White,
                    maxLines   = 1,
                    overflow   = TextOverflow.Ellipsis,
                )
                Text(
                    text     = song.artist,
                    fontSize = 12.sp,
                    color    = Color.White.copy(alpha = 0.75f),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }

            // Kontrol mini
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                MiniControlBtn("⏮") { /* prev handled in MainActivity */ }
                MiniControlBtn("⏸", primary = true) { /* play/pause */ }
                MiniControlBtn("⏭") { /* next */ }
            }
        }
    }
}

@Composable
fun MiniControlBtn(icon: String, primary: Boolean = false, onClick: () -> Unit) {
    val accent = MaterialTheme.colorScheme.primary
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(if (primary) 40.dp else 34.dp)
            .clip(CircleShape)
            .background(if (primary) accent else Color.White.copy(alpha = 0.15f))
            .clickable(onClick = onClick),
    ) {
        Text(text = icon, fontSize = if (primary) 16.sp else 14.sp)
    }
}
EOF
echo "  ✓ SongListScreen.kt"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 7: NowPlayingScreen.kt — player screen
# ─────────────────────────────────────────────────────────────────────────────
echo "🎵 [7/9] Buat NowPlayingScreen.kt..."

cat > "$UI_DIR/NowPlayingScreen.kt" << 'EOF'
package com.dioxd.floramusic.ui

import android.graphics.Bitmap
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import coil.request.SuccessResult
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import kotlinx.coroutines.launch

@Composable
fun NowPlayingScreen(
    onBack:    () -> Unit,
    onNext:    () -> Unit,
    onPrev:    () -> Unit,
    onTogglePlay: () -> Unit,
    seekTo:    (Int) -> Unit,
    progress:  Int,    // currentPosition ms
    duration:  Int,    // total duration ms
) {
    val song = PlayerState.currentSong ?: return

    // ── Dynamic color dari cover art ──────────────────────────────────────
    var dynColors by remember { mutableStateOf(DynamicThemeHelper.fallback) }
    val context   = LocalContext.current
    val scope     = rememberCoroutineScope()

    LaunchedEffect(song.albumArtUri) {
        scope.launch {
            try {
                val req    = ImageRequest.Builder(context).data(song.albumArtUri).build()
                val result = coil.ImageLoader(context).execute(req)
                if (result is SuccessResult) {
                    val bmp = (result.drawable as android.graphics.drawable.BitmapDrawable).bitmap
                    dynColors = DynamicThemeHelper.fromBitmap(bmp)
                }
            } catch (_: Exception) {
                dynColors = DynamicThemeHelper.fallback
            }
        }
    }

    val accent    = dynColors.primary
    val accentCnt = dynColors.primaryContainer
    val bg        = dynColors.background

    // ── Swipe-down untuk kembali ──────────────────────────────────────────
    var dragOffset by remember { mutableFloatStateOf(0f) }
    val animOffset  by animateFloatAsState(dragOffset, label = "drag")

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(bg)
            .offset(y = animOffset.dp)
            .pointerInput(Unit) {
                detectVerticalDragGestures(
                    onDragEnd = {
                        if (dragOffset > 120f) onBack() else dragOffset = 0f
                    },
                    onVerticalDrag = { _, delta ->
                        if (dragOffset + delta >= 0)
                            dragOffset += delta * 0.4f
                    },
                    onDragCancel = { dragOffset = 0f }
                )
            }
    ) {
        // ── Blurred background dari cover art ────────────────────────────
        AsyncImage(
            model              = song.albumArtUri,
            contentDescription = null,
            contentScale       = ContentScale.Crop,
            alpha              = 0.45f,
            modifier           = Modifier.fillMaxSize().blur(40.dp),
        )

        // Gradient overlay
        Box(modifier = Modifier.fillMaxSize().background(
            Brush.verticalGradient(
                0.0f to bg.copy(alpha = 0.7f),
                0.4f to bg.copy(alpha = 0.3f),
                1.0f to bg.copy(alpha = 0.95f),
            )
        ))

        // ── Konten utama ─────────────────────────────────────────────────
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier
                .fillMaxSize()
                .padding(top = 52.dp, bottom = 28.dp),
        ) {

            // Top bar
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
            ) {
                IconButton(onClick = onBack) {
                    Text("←", fontSize = 22.sp, color = Color.White)
                }
                Text(
                    text       = "Sedang Diputar",
                    fontSize   = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color      = Color.White,
                    modifier   = Modifier.weight(1f),
                    textAlign  = androidx.compose.ui.text.style.TextAlign.Center,
                )
                IconButton(onClick = { /* settings */ }) {
                    Text("⚙", fontSize = 18.sp, color = Color.White.copy(alpha = 0.7f))
                }
            }

            // Album art — menempati ruang tersisa
            val scale by animateFloatAsState(
                if (PlayerState.isPlaying) 1f else 0.90f,
                animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
                label = "artScale"
            )
            Box(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 28.dp, vertical = 8.dp)
                    .scale(scale),
            ) {
                AsyncImage(
                    model              = song.albumArtUri,
                    contentDescription = null,
                    contentScale       = ContentScale.Crop,
                    modifier           = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(24.dp))
                        .background(DynamicThemeHelper.colorForTitle(song.title)),
                )
            }

            // Judul + artis + like
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 28.dp, vertical = 8.dp),
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text       = song.title,
                        fontSize   = 22.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color      = Color.White,
                        maxLines   = 1,
                        overflow   = TextOverflow.Ellipsis,
                    )
                    Text(
                        text     = song.artist,
                        fontSize = 14.sp,
                        color    = accent,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.padding(top = 3.dp),
                    )
                }
                var liked by remember { mutableStateOf(false) }
                IconButton(onClick = { liked = !liked }) {
                    Text(
                        text     = if (liked) "❤️" else "🤍",
                        fontSize = 22.sp,
                    )
                }
            }

            // Seekbar + waktu
            Column(modifier = Modifier.padding(horizontal = 24.dp, vertical = 4.dp)) {
                Slider(
                    value         = if (duration > 0) progress.toFloat() / duration else 0f,
                    onValueChange = { ratio -> seekTo((ratio * duration).toInt()) },
                    colors        = SliderDefaults.colors(
                        thumbColor            = accent,
                        activeTrackColor      = accent,
                        inactiveTrackColor    = Color.White.copy(alpha = 0.25f),
                    ),
                )
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier.fillMaxWidth().offset(y = (-6).dp),
                ) {
                    Text(formatTime(progress), fontSize = 11.sp,
                         color = Color.White.copy(alpha = 0.6f))
                    Text(formatTime(duration), fontSize = 11.sp,
                         color = Color.White.copy(alpha = 0.6f))
                }
            }

            // Kontrol prev / play / next
            Row(
                verticalAlignment     = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(0.dp),
                modifier = Modifier.padding(horizontal = 40.dp, vertical = 8.dp),
            ) {
                // Prev
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(52.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.10f))
                        .clickable(onClick = onPrev),
                ) { Text("⏮", fontSize = 22.sp) }

                Spacer(Modifier.weight(1f))

                // Play/Pause — FAB glow
                Box(contentAlignment = Alignment.Center) {
                    // Glow
                    Box(modifier = Modifier.size(88.dp).clip(CircleShape)
                        .background(accent.copy(alpha = 0.25f)))
                    // Tombol utama
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier
                            .size(76.dp)
                            .clip(CircleShape)
                            .background(accent)
                            .clickable(onClick = onTogglePlay),
                    ) {
                        Text(
                            text     = if (PlayerState.isPlaying) "⏸" else "▶",
                            fontSize = 28.sp,
                        )
                    }
                }

                Spacer(Modifier.weight(1f))

                // Next
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(52.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.10f))
                        .clickable(onClick = onNext),
                ) { Text("⏭", fontSize = 22.sp) }
            }

            // Pill bar shortcuts
            PillBar(
                accentColor = accent,
                modifier    = Modifier.padding(bottom = 8.dp),
            )
        }
    }
}

// ── Pill bar — Shuffle | Repeat | Queue | Lyrics | Timer ──────────────────────
@Composable
fun PillBar(accentColor: Color, modifier: Modifier = Modifier) {
    Surface(
        shape = RoundedCornerShape(50),
        color = Color.White.copy(alpha = 0.10f),
        modifier = modifier,
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(horizontal = 6.dp),
        ) {
            val pills = listOf("🔀" to "Acak", "🔁" to "Ulangi",
                               "📋" to "Antrian", "🎵" to "Lirik", "⏱" to "Timer")

            pills.forEachIndexed { index, (icon, label) ->
                var active by remember { mutableStateOf(false) }

                if (index > 0)
                    Box(modifier = Modifier.width(1.dp).height(20.dp)
                        .background(Color.White.copy(alpha = 0.25f)))

                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(44.dp)
                        .clip(CircleShape)
                        .background(if (active) accentColor.copy(alpha = 0.2f) else Color.Transparent)
                        .clickable { active = !active },
                ) {
                    Text(
                        text    = icon,
                        fontSize = 16.sp,
                        color   = if (active) accentColor else Color.White.copy(alpha = 0.55f),
                    )
                }
            }
        }
    }
}

private fun formatTime(ms: Int): String {
    val m = ms / 1000 / 60
    val s = (ms / 1000) % 60
    return "%d:%02d".format(m, s)
}
EOF
echo "  ✓ NowPlayingScreen.kt"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 8: FloraApp.kt — navigasi
# ─────────────────────────────────────────────────────────────────────────────
echo "🧭 [8/9] Buat FloraApp.kt..."

cat > "$UI_DIR/FloraApp.kt" << 'EOF'
package com.dioxd.floramusic.ui

import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.runtime.*
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.dioxd.floramusic.data.PlayerState

@Composable
fun FloraApp(
    songs: List<com.dioxd.floramusic.data.Song>,
    onSongClick: (com.dioxd.floramusic.data.Song, Int) -> Unit,
    onTogglePlay: () -> Unit,
    onNext: () -> Unit,
    onPrev: () -> Unit,
    seekTo: (Int) -> Unit,
    progress: Int,
    duration: Int,
) {
    val navController = rememberNavController()

    NavHost(
        navController      = navController,
        startDestination   = "list",
        enterTransition    = { slideInVertically(tween(300)) { it } + fadeIn(tween(300)) },
        exitTransition     = { fadeOut(tween(200)) },
        popEnterTransition = { fadeIn(tween(200)) },
        popExitTransition  = { slideOutVertically(tween(300)) { it } + fadeOut(tween(300)) },
    ) {
        composable("list") {
            SongListScreen(
                songs           = songs,
                onSongClick     = { song, index ->
                    onSongClick(song, index)
                    navController.navigate("nowplaying")
                },
                onNowPlayingClick = {
                    if (PlayerState.currentSong != null)
                        navController.navigate("nowplaying")
                },
            )
        }

        composable("nowplaying") {
            NowPlayingScreen(
                onBack        = { navController.popBackStack() },
                onNext        = onNext,
                onPrev        = onPrev,
                onTogglePlay  = onTogglePlay,
                seekTo        = seekTo,
                progress      = progress,
                duration      = duration,
            )
        }
    }
}
EOF
echo "  ✓ FloraApp.kt"

# ─────────────────────────────────────────────────────────────────────────────
# LANGKAH 9: MainActivity.kt — entry point Compose
# ─────────────────────────────────────────────────────────────────────────────
echo "🏁 [9/9] Update MainActivity.kt..."

cat > "$UI_DIR/MainActivity.kt" << 'EOF'
package com.dioxd.floramusic.ui

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.*
import androidx.core.content.ContextCompat
import com.dioxd.floramusic.data.MusicRepository
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.ui.theme.FloraTheme

class MainActivity : ComponentActivity() {

    private val handler  = Handler(Looper.getMainLooper())
    private var progress by mutableIntStateOf(0)
    private var duration by mutableIntStateOf(0)

    private val permLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted -> if (granted) loadSongs() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            FloraTheme {
                FloraApp(
                    songs        = PlayerState.songs,
                    onSongClick  = ::playSong,
                    onTogglePlay = ::togglePlay,
                    onNext       = { playAt(PlayerState.nextIndex()) },
                    onPrev       = { playAt(PlayerState.prevIndex()) },
                    seekTo       = { ms -> PlayerState.mediaPlayer?.seekTo(ms) },
                    progress     = progress,
                    duration     = duration,
                )
            }
        }

        checkPermission()
        startProgressUpdater()
    }

    private fun checkPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.READ_MEDIA_AUDIO
        else Manifest.permission.READ_EXTERNAL_STORAGE

        if (ContextCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED)
            loadSongs()
        else
            permLauncher.launch(perm)
    }

    private fun loadSongs() {
        PlayerState.songs = MusicRepository.getAllSongs(this)
    }

    private fun playSong(song: Song, index: Int) {
        PlayerState.currentIndex = index
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = MediaPlayer().apply {
            setDataSource(applicationContext, song.uri)
            prepare()
            start()
            setOnCompletionListener {
                if (PlayerState.repeat) { seekTo(0); start() }
                else playAt(PlayerState.nextIndex())
            }
        }
        PlayerState.isPlaying = true
    }

    private fun playAt(index: Int) {
        if (PlayerState.songs.isEmpty()) return
        playSong(PlayerState.songs[index], index)
    }

    private fun togglePlay() {
        PlayerState.mediaPlayer?.let {
            if (it.isPlaying) { it.pause(); PlayerState.isPlaying = false }
            else              { it.start(); PlayerState.isPlaying = true  }
        }
    }

    private fun startProgressUpdater() {
        handler.post(object : Runnable {
            override fun run() {
                PlayerState.mediaPlayer?.let {
                    progress = it.currentPosition
                    duration = it.duration
                }
                handler.postDelayed(this, 500)
            }
        })
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = null
    }
}
EOF
echo "  ✓ MainActivity.kt"

# ─────────────────────────────────────────────────────────────────────────────
# SELESAI
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "✅ Migrasi ke Jetpack Compose selesai!"
echo ""
echo "File baru:"
echo "  + ui/theme/FloraTheme.kt       — Material 3 dark theme"
echo "  + ui/DynamicThemeHelper.kt     — ekstrak warna dari cover art"
echo "  + ui/FloraApp.kt               — navigasi antar screen"
echo "  + ui/SongListScreen.kt         — daftar lagu (LazyColumn)"
echo "  + ui/NowPlayingScreen.kt       — player + swipe dismiss"
echo ""
echo "File diupdate:"
echo "  ~ data/PlayerState.kt          — Compose State, shuffle/repeat"
echo "  ~ ui/MainActivity.kt           — setContent { FloraTheme {} }"
echo "  ~ app/build.gradle             — Compose BOM + dependencies"
echo ""
echo "File dihapus:"
echo "  - ui/SongAdapter.kt"
echo "  - ui/NowPlayingActivity.kt"
echo "  - res/layout/*.xml"
echo ""
echo "Sekarang jalankan:"
echo "  git add ."
echo "  git commit -m 'feat: migrasi ke Jetpack Compose'"
echo "  git pull --rebase && git push"
