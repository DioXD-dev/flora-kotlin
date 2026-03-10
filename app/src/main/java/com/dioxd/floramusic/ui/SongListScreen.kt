package com.dioxd.floramusic.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.PointerInputChange
import androidx.compose.ui.input.pointer.pointerInput
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

// ─── Main screen ─────────────────────────────────────────────────────────────
@Composable
fun SongListScreen(
    songs:            List<Song>,
    onSongClick:      (Song, Int) -> Unit,
    onNowPlayingClick: () -> Unit,
    onTogglePlay:     () -> Unit,
    onNext:           () -> Unit,
    onPrev:           () -> Unit,
    progress:         Int,
    duration:         Int,
) {
    var query by remember { mutableStateOf("") }
    val focusManager = LocalFocusManager.current
    val listState = rememberLazyListState()

    val filtered = remember(query, songs) {
        if (query.isBlank()) songs
        else songs.filter {
            it.title.contains(query, ignoreCase = true) ||
            it.artist.contains(query, ignoreCase = true) ||
            it.album.contains(query, ignoreCase = true)
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {

        Column(modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
        ) {

            // ── Header ───────────────────────────────────────────────────────
            Row(
                modifier          = Modifier
                    .fillMaxWidth()
                    .padding(start = 20.dp, end = 12.dp, top = 16.dp, bottom = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text       = "🌿 Flora Music",
                        fontSize   = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color      = MaterialTheme.colorScheme.onSurface,
                    )
                    Text(
                        text     = "${songs.size} lagu",
                        fontSize = 12.sp,
                        color    = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }

            // ── Search bar ───────────────────────────────────────────────────
            OutlinedTextField(
                value         = query,
                onValueChange = { query = it },
                modifier      = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                placeholder   = { Text("Cari lagu, artis, album…") },
                leadingIcon   = { Icon(Icons.Default.Search, null) },
                trailingIcon  = if (query.isNotEmpty()) {{
                    IconButton(onClick = { query = ""; focusManager.clearFocus() }) {
                        Icon(Icons.Default.Clear, "Hapus")
                    }
                }} else null,
                singleLine    = true,
                shape         = RoundedCornerShape(16.dp),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                keyboardActions = KeyboardActions(onSearch = { focusManager.clearFocus() }),
            )

            Spacer(Modifier.height(4.dp))

            // ── Song list ────────────────────────────────────────────────────
            LazyColumn(
                state           = listState,
                modifier        = Modifier.weight(1f),
                contentPadding  = androidx.compose.foundation.layout.PaddingValues(
                    start  = 12.dp,
                    end    = 12.dp,
                    top    = 4.dp,
                    bottom = 160.dp,
                ),
                verticalArrangement = Arrangement.spacedBy(4.dp),
            ) {
                itemsIndexed(filtered, key = { _, s -> s.id }) { _, song ->
                    SongCard(
                        song      = song,
                        isPlaying = song.id == PlayerState.currentSong?.id,
                        accent    = MaterialTheme.colorScheme.secondary,
                        onClick   = { onSongClick(song, songs.indexOf(song)) },
                    )
                }
            }
        }

        // ── Mini player (muncul di bawah saat ada lagu) ───────────────────────
        AnimatedVisibility(
            visible = PlayerState.currentSong != null,
            modifier = Modifier.align(Alignment.BottomCenter),
            enter    = slideInVertically { it } + fadeIn(),
            exit     = slideOutVertically { it } + fadeOut(),
        ) {
            PlayerState.currentSong?.let { song ->
                MiniBar(
                    song      = song,
                    accent    = MaterialTheme.colorScheme.secondary,
                    progress  = progress,
                    duration  = duration,
                    onNext    = onNext,
                    onPrev    = onPrev,
                    onToggle  = onTogglePlay,
                    onClick   = onNowPlayingClick,
                    onDismiss = { /* snap back handled inside */ },
                    modifier  = Modifier
                        .padding(horizontal = 12.dp)
                        .navigationBarsPadding()
                        .padding(bottom = 72.dp),
                )
            }
        }
    }
}

// ─── SongCard ─────────────────────────────────────────────────────────────────
@Composable
fun SongCard(
    song:      Song,
    isPlaying: Boolean,
    accent:    Color,
    onClick:   () -> Unit,
) {
    Surface(
        onClick      = onClick,
        shape        = RoundedCornerShape(16.dp),
        tonalElevation = if (isPlaying) 4.dp else 0.dp,
        border       = if (isPlaying)
            androidx.compose.foundation.BorderStroke(1.5.dp, accent.copy(0.5f))
        else null,
        modifier     = Modifier.fillMaxWidth(),
    ) {
        Row(
            modifier          = Modifier.padding(10.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Strip kiri saat aktif
            if (isPlaying) {
                Box(
                    Modifier
                        .width(3.dp)
                        .height(48.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(accent)
                )
                Spacer(Modifier.width(8.dp))
            }

            // Album art
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(DynamicThemeHelper.colorForTitle(song.title)),
                contentAlignment = Alignment.Center,
            ) {
                AsyncImage(
                    model              = song.albumArtUri,
                    contentDescription = null,
                    contentScale       = ContentScale.Crop,
                    modifier           = Modifier.fillMaxSize().clip(RoundedCornerShape(12.dp)),
                )
            }

            Spacer(Modifier.width(12.dp))

            // Info
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text       = song.title,
                    fontSize   = 14.sp,
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

            // Durasi
            Text(
                text     = song.durationText,
                fontSize = 11.sp,
                color    = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(start = 8.dp),
            )
        }
    }
}

// ─── MiniBar ──────────────────────────────────────────────────────────────────
@Composable
fun MiniBar(
    song:      Song,
    accent:    Color,
    progress:  Int,
    duration:  Int,
    onNext:    () -> Unit,
    onPrev:    () -> Unit,
    onToggle:  () -> Unit,
    onClick:   () -> Unit,
    onDismiss: () -> Unit,
    modifier:  Modifier = Modifier,
) {
    var offsetY by remember { mutableFloatStateOf(0f) }
    val animY   by animateFloatAsState(
        targetValue    = offsetY,
        animationSpec  = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
        label          = "miniY",
    )

    Surface(
        shape          = RoundedCornerShape(24.dp),
        tonalElevation = 8.dp,
        color          = MaterialTheme.colorScheme.secondaryContainer,
        modifier       = modifier
            .fillMaxWidth()
            .offset(y = animY.dp)
            .clickable(onClick = onClick)
            .pointerInput(Unit) {
                detectVerticalDragGestures(
                    onVerticalDrag = { _: PointerInputChange, delta: Float ->
                        if (offsetY + delta > 0f) offsetY += delta * 0.4f
                    },
                    onDragEnd = {
                        if (offsetY > 80f) onDismiss()
                        else offsetY = 0f
                    },
                    onDragCancel = { offsetY = 0f },
                )
            },
    ) {
        Column {
            Row(
                modifier          = Modifier.padding(start = 12.dp, end = 4.dp, top = 10.dp, bottom = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Album art
                Box(
                    modifier = Modifier
                        .size(44.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(DynamicThemeHelper.colorForTitle(song.title)),
                    contentAlignment = Alignment.Center,
                ) {
                    AsyncImage(
                        model            = song.albumArtUri,
                        contentDescription = null,
                        contentScale     = ContentScale.Crop,
                        modifier         = Modifier.fillMaxSize().clip(RoundedCornerShape(10.dp)),
                    )
                }

                Spacer(Modifier.width(12.dp))

                // Info
                Column(Modifier.weight(1f)) {
                    Text(
                        text       = song.title,
                        fontSize   = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color      = MaterialTheme.colorScheme.onSecondaryContainer,
                        maxLines   = 1,
                        overflow   = TextOverflow.Ellipsis,
                    )
                    Text(
                        text     = song.artist,
                        fontSize = 12.sp,
                        color    = MaterialTheme.colorScheme.onSecondaryContainer.copy(0.7f),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }

                // Controls
                IconButton(onClick = onPrev) {
                    Icon(Icons.Default.SkipPrevious, "Prev",
                        tint = accent)
                }
                Box(
                    modifier         = Modifier.size(40.dp).clip(CircleShape).background(accent),
                    contentAlignment = Alignment.Center,
                ) {
                    IconButton(onClick = onToggle) {
                        Icon(
                            if (PlayerState.isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                            "Play",
                            tint = Color.White,
                        )
                    }
                }
                IconButton(onClick = onNext) {
                    Icon(Icons.Default.SkipNext, "Next",
                        tint = accent)
                }
            }

            // Progress bar tipis di bawah minibar
            if (duration > 0) {
                LinearProgressIndicator(
                    progress        = { progress.toFloat() / duration },
                    modifier        = Modifier
                        .fillMaxWidth()
                        .height(3.dp)
                        .padding(horizontal = 12.dp)
                        .padding(bottom = 6.dp)
                        .clip(RoundedCornerShape(2.dp)),
                    color           = accent,
                    trackColor      = accent.copy(0.2f),
                )
            } else {
                Spacer(Modifier.height(8.dp))
            }
        }
    }
}
