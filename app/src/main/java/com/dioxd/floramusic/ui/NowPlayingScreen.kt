package com.dioxd.floramusic.ui

import android.graphics.Bitmap
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.*
import androidx.compose.ui.graphics.*
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.dioxd.floramusic.data.PlayerState

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
    val song    = PlayerState.currentSong
    val accent  = Color(0xFFE8A87C)
    var offsetY by remember { mutableFloatStateOf(0f) }
    val animY   by animateFloatAsState(offsetY,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
        label = "offsetY"
    )

    // Swipe-down dismiss
    Box(
        modifier = Modifier
            .fillMaxSize()
            .offset(y = animY.dp)
            .pointerInput(Unit) {
                detectVerticalDragGestures(
                    onVerticalDrag = { _, delta ->
                        if (offsetY + delta > 0) offsetY += delta * 0.5f
                    },
                    onDragEnd = {
                        if (offsetY > 120f) onBack()
                        else offsetY = 0f
                    },
                    onDragCancel = { offsetY = 0f }
                )
            }
    ) {
        // Background blur + gradient
        song?.let {
            AsyncImage(
                model              = it.albumArtUri,
                contentDescription = null,
                contentScale       = ContentScale.Crop,
                modifier           = Modifier.fillMaxSize().alpha(0.55f).blur(32.dp),
            )
        }

        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        listOf(Color.Black.copy(0.6f), Color.Black.copy(0.9f))
                    )
                )
        )

        Column(
            modifier            = Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {

            // ── Top bar ──────────────────────────────────────────────────────
            Row(
                modifier       = Modifier.fillMaxWidth().padding(horizontal = 4.dp, vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconButton(onClick = onBack) {
                    Icon(Icons.Default.KeyboardArrowDown, "Kembali",
                        tint = Color.White, modifier = Modifier.size(28.dp))
                }
                Text(
                    text       = "Sedang Diputar",
                    modifier   = Modifier.weight(1f),
                    color      = Color.White,
                    fontSize   = 15.sp,
                    fontWeight = FontWeight.Bold,
                    textAlign  = androidx.compose.ui.text.style.TextAlign.Center,
                )
                IconButton(onClick = { /* settings */ }) {
                    Icon(Icons.Default.Settings, "Pengaturan", tint = Color.White)
                }
            }

            // ── Album art besar ───────────────────────────────────────────────
            Box(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 32.dp, vertical = 12.dp)
                    .aspectRatio(1f)
                    .clip(RoundedCornerShape(20.dp))
                    .background(Color.White.copy(0.1f)),
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
                    modifier = Modifier.size(80.dp).align(Alignment.Center),
                )
            }

            // ── Judul + Artis + Like ──────────────────────────────────────────
            var liked by remember { mutableStateOf(false) }
            Row(
                modifier          = Modifier.fillMaxWidth().padding(horizontal = 28.dp, vertical = 4.dp),
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
                        color    = accent,
                        fontSize = 14.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
                IconButton(onClick = { liked = !liked }) {
                    Icon(
                        if (liked) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        "Suka",
                        tint = if (liked) accent else Color.White,
                    )
                }
            }

            // ── Seekbar ───────────────────────────────────────────────────────
            Column(Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 4.dp)) {
                Slider(
                    value         = if (duration > 0) progress.toFloat() / duration else 0f,
                    onValueChange = { seekTo((it * duration).toInt()) },
                    colors        = SliderDefaults.colors(
                        thumbColor        = accent,
                        activeTrackColor  = accent,
                        inactiveTrackColor = Color.White.copy(0.25f),
                    ),
                )
                Row(Modifier.fillMaxWidth()) {
                    Text(formatMs(progress), color = Color.White.copy(0.7f), fontSize = 11.sp)
                    Spacer(Modifier.weight(1f))
                    Text(formatMs(duration),  color = Color.White.copy(0.7f), fontSize = 11.sp)
                }
            }

            // ── Kontrol ───────────────────────────────────────────────────────
            Row(
                modifier          = Modifier.fillMaxWidth().padding(horizontal = 36.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                // Prev
                IconButton(onClick = onPrev, modifier = Modifier.size(52.dp)) {
                    Icon(Icons.Default.SkipPrevious, "Sebelumnya",
                        tint = accent, modifier = Modifier.size(32.dp))
                }

                // Play/Pause — bulat oranye + glow
                Box(
                    modifier          = Modifier.size(72.dp),
                    contentAlignment  = Alignment.Center,
                ) {
                    // Glow
                    Box(Modifier.size(72.dp).clip(CircleShape)
                        .background(accent.copy(alpha = 0.25f)))
                    Box(Modifier.size(62.dp).clip(CircleShape)
                        .background(accent))
                    IconButton(onClick = onTogglePlay, modifier = Modifier.size(62.dp)) {
                        Icon(
                            if (PlayerState.isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                            "Play/Pause",
                            tint     = Color.White,
                            modifier = Modifier.size(34.dp),
                        )
                    }
                }

                // Next
                IconButton(onClick = onNext, modifier = Modifier.size(52.dp)) {
                    Icon(Icons.Default.SkipNext, "Berikutnya",
                        tint = accent, modifier = Modifier.size(32.dp))
                }
            }

            // ── Pill shortcuts ────────────────────────────────────────────────
            Surface(
                modifier      = Modifier.padding(bottom = 24.dp),
                shape         = CircleShape,
                color         = Color.White.copy(alpha = 0.12f),
            ) {
                Row(
                    modifier          = Modifier.padding(horizontal = 6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    var shuffle by remember { mutableStateOf(PlayerState.shuffle) }
                    var repeat  by remember { mutableStateOf(PlayerState.repeat) }

                    PillIcon(Icons.Default.Shuffle, "Acak", if (shuffle) accent else Color.White) {
                        PlayerState.shuffle = !PlayerState.shuffle; shuffle = PlayerState.shuffle
                    }
                    PillDivider()
                    PillIcon(Icons.Default.Repeat, "Ulangi", if (repeat) accent else Color.White) {
                        PlayerState.repeat = !PlayerState.repeat; repeat = PlayerState.repeat
                    }
                    PillDivider()
                    PillIcon(Icons.Default.QueueMusic, "Antrian", Color.White) {}
                    PillDivider()
                    PillIcon(Icons.Default.Lyrics, "Lirik", Color.White) {}
                    PillDivider()
                    PillIcon(Icons.Default.Timer, "Timer", Color.White) {}
                }
            }
        }
    }
}

@Composable
private fun PillIcon(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    desc: String,
    tint: Color,
    onClick: () -> Unit,
) {
    IconButton(onClick = onClick, modifier = Modifier.size(44.dp)) {
        Icon(icon, desc, tint = tint.copy(if (tint == Color.White) 0.7f else 1f),
            modifier = Modifier.size(20.dp))
    }
}

@Composable
private fun PillDivider() {
    Box(Modifier.width(1.dp).height(20.dp).background(Color.White.copy(0.2f)))
}

private fun formatMs(ms: Int): String {
    val m = ms / 1000 / 60
    val s = (ms / 1000) % 60
    return "%d:%02d".format(m, s)
}
