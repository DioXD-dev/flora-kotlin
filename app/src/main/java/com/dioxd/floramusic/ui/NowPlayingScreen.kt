package com.dioxd.floramusic.ui

import android.media.MediaPlayer
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.Lyrics
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.QueueMusic
import androidx.compose.material.icons.filled.Repeat
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Shuffle
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.PointerInputChange
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song

private val Accent = Color(0xFFE8A87C)

@Composable
fun NowPlayingScreen(
    onBack:       () -> Unit,
    onNext:       () -> Unit,
    onPrev:       () -> Unit,
    onTogglePlay: () -> Unit,
    seekTo:       (Int) -> Unit,
    progress:     Int,
    duration:     Int,
) {
    val song = PlayerState.currentSong

    // Swipe-down to dismiss
    var offsetY by remember { mutableFloatStateOf(0f) }
    val animY   by animateFloatAsState(
        targetValue   = offsetY,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
        label         = "npY",
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .offset(y = animY.dp)
            .pointerInput(Unit) {
                detectVerticalDragGestures(
                    onVerticalDrag = { _: PointerInputChange, delta: Float ->
                        if (offsetY + delta > 0f) offsetY += delta * 0.5f
                    },
                    onDragEnd    = { if (offsetY > 120f) onBack() else offsetY = 0f },
                    onDragCancel = { offsetY = 0f },
                )
            },
    ) {

        // ── Background: blur album art ──────────────────────────────────────
        song?.let {
            AsyncImage(
                model              = it.albumArtUri,
                contentDescription = null,
                contentScale       = ContentScale.Crop,
                modifier           = Modifier
                    .fillMaxSize()
                    .alpha(0.55f)
                    .blur(36.dp),
            )
        }

        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        0f  to Color.Black.copy(0.55f),
                        0.4f to Color.Black.copy(0.3f),
                        1f  to Color.Black.copy(0.92f),
                    )
                )
        )

        // Fallback background kalau tidak ada cover
        if (song == null) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color(0xFF2d2420))
            )
        }

        // ── Konten ────────────────────────────────────────────────────────
        Column(
            modifier            = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {

            // Top bar: back + judul + settings
            Row(
                modifier          = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconButton(onClick = onBack) {
                    Icon(Icons.Default.KeyboardArrowDown, "Kembali",
                        tint = Color.White, modifier = Modifier.size(30.dp))
                }
                Text(
                    text       = "Sedang Diputar",
                    modifier   = Modifier.weight(1f),
                    color      = Color.White,
                    fontSize   = 15.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign  = TextAlign.Center,
                )
                IconButton(onClick = { /* TODO: settings */ }) {
                    Icon(Icons.Default.Settings, "Pengaturan", tint = Color.White)
                }
            }

            // Album art — kotak persegi, radius 20dp
            Box(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 32.dp, vertical = 8.dp)
                    .aspectRatio(1f)
                    .clip(RoundedCornerShape(20.dp))
                    .background(
                        if (song != null) DynamicThemeHelper.colorForTitle(song.title)
                        else Color(0xFF3d3028)
                    ),
                contentAlignment = Alignment.Center,
            ) {
                song?.let {
                    AsyncImage(
                        model              = it.albumArtUri,
                        contentDescription = it.title,
                        contentScale       = ContentScale.Crop,
                        modifier           = Modifier.fillMaxSize(),
                    )
                } ?: Icon(
                    Icons.Default.MusicNote, null,
                    tint     = Color.White.copy(0.4f),
                    modifier = Modifier.size(80.dp),
                )
            }

            // Judul + artis + like
            var liked by remember { mutableStateOf(false) }
            Row(
                modifier          = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 28.dp, vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(Modifier.weight(1f)) {
                    Text(
                        text       = song?.title ?: "—",
                        color      = Color.White,
                        fontSize   = 21.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines   = 1,
                        overflow   = TextOverflow.Ellipsis,
                    )
                    Text(
                        text     = song?.artist ?: "—",
                        color    = Accent,
                        fontSize = 14.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
                IconButton(onClick = { liked = !liked }) {
                    Icon(
                        if (liked) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        "Suka",
                        tint = if (liked) Accent else Color.White,
                    )
                }
            }

            // Seekbar + waktu
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 4.dp),
            ) {
                Slider(
                    value         = if (duration > 0) progress.toFloat() / duration else 0f,
                    onValueChange = { seekTo((it * duration).toInt()) },
                    colors        = SliderDefaults.colors(
                        thumbColor         = Accent,
                        activeTrackColor   = Accent,
                        inactiveTrackColor = Color.White.copy(0.25f),
                    ),
                )
                Row(Modifier.fillMaxWidth()) {
                    Text(fmtMs(progress), color = Color.White.copy(0.7f), fontSize = 11.sp)
                    Spacer(Modifier.weight(1f))
                    Text(fmtMs(duration),  color = Color.White.copy(0.7f), fontSize = 11.sp)
                }
            }

            // Kontrol: prev / play-pause / next
            Row(
                modifier          = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 36.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = androidx.compose.foundation.layout.Arrangement.SpaceBetween,
            ) {
                // Prev — aksen
                IconButton(onClick = onPrev, modifier = Modifier.size(52.dp)) {
                    Icon(Icons.Default.SkipPrevious, "Sebelumnya",
                        tint = Accent, modifier = Modifier.size(34.dp))
                }

                // Play/Pause — bulat oranye + glow
                Box(contentAlignment = Alignment.Center) {
                    // Glow ring luar
                    Box(Modifier.size(80.dp).clip(CircleShape)
                        .background(Accent.copy(alpha = 0.2f)))
                    // Glow ring dalam
                    Box(Modifier.size(72.dp).clip(CircleShape)
                        .background(Accent.copy(alpha = 0.35f)))
                    // Tombol utama
                    Box(Modifier.size(62.dp).clip(CircleShape)
                        .background(Accent),
                        contentAlignment = Alignment.Center,
                    ) {
                        IconButton(onClick = onTogglePlay) {
                            Icon(
                                if (PlayerState.isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                                "Play/Pause",
                                tint     = Color.White,
                                modifier = Modifier.size(34.dp),
                            )
                        }
                    }
                }

                // Next — aksen
                IconButton(onClick = onNext, modifier = Modifier.size(52.dp)) {
                    Icon(Icons.Default.SkipNext, "Berikutnya",
                        tint = Accent, modifier = Modifier.size(34.dp))
                }
            }

            // ── Satu pill bar: Shuffle | Repeat | Queue | Lyrics | Timer ──
            var shuffle by remember { mutableStateOf(PlayerState.shuffle) }
            var repeat  by remember { mutableStateOf(PlayerState.repeat) }

            Surface(
                shape   = CircleShape,
                color   = Color.White.copy(alpha = 0.12f),
                modifier = Modifier.padding(bottom = 20.dp),
            ) {
                Row(
                    modifier          = Modifier.padding(horizontal = 4.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    PillBtn(Icons.Default.Shuffle, "Acak",
                        if (shuffle) Accent else Color.White.copy(0.6f)) {
                        PlayerState.shuffle = !PlayerState.shuffle
                        shuffle = PlayerState.shuffle
                    }
                    PillSep()
                    PillBtn(Icons.Default.Repeat, "Ulangi",
                        if (repeat) Accent else Color.White.copy(0.6f)) {
                        PlayerState.repeat = !PlayerState.repeat
                        repeat = PlayerState.repeat
                    }
                    PillSep()
                    PillBtn(Icons.Default.QueueMusic, "Antrian",
                        Color.White.copy(0.6f)) {}
                    PillSep()
                    PillBtn(Icons.Default.Lyrics, "Lirik",
                        Color.White.copy(0.6f)) {}
                    PillSep()
                    PillBtn(Icons.Default.Timer, "Timer",
                        Color.White.copy(0.6f)) {}
                }
            }
        }
    }
}

@Composable
private fun PillBtn(icon: ImageVector, desc: String, tint: Color, onClick: () -> Unit) {
    IconButton(onClick = onClick, modifier = Modifier.size(44.dp)) {
        Icon(icon, desc, tint = tint, modifier = Modifier.size(20.dp))
    }
}

@Composable
private fun PillSep() {
    Box(Modifier.width(1.dp).height(20.dp).background(Color.White.copy(0.2f)))
}

private fun fmtMs(ms: Int): String {
    val m = ms / 1000 / 60
    val s = (ms / 1000) % 60
    return "%d:%02d".format(m, s)
}
