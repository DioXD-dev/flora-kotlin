#!/bin/bash
# Flora Music — Rombak UI Halaman Utama
# Jalankan di dalam folder ~/flora-kotlin

echo "🌿 Merombak UI halaman utama..."
echo ""

if [ ! -f "app/build.gradle.kts" ]; then
    echo "❌ Jalankan di dalam folder ~/flora-kotlin!"
    exit 1
fi

UI_DIR="app/src/main/java/com/dioxd/floramusic/ui"
mkdir -p "$UI_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# SongListScreen.kt — UI utama yang dirombak total
# ─────────────────────────────────────────────────────────────────────────────
cat > "$UI_DIR/SongListScreen.kt" << 'KOTLIN'
package com.dioxd.floramusic.ui

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.*
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.*
import coil.compose.AsyncImage
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import kotlin.math.PI

// ─── Nav destinations ────────────────────────────────────────────────────────
data class NavItem(val icon: String, val label: String)

val NAV_ITEMS = listOf(
    NavItem("🎵", "Librari"),
    NavItem("❤️", "Favorit"),
    NavItem("📋", "Playlist"),
    NavItem("🎙", "Artis"),
    NavItem("💿", "Album"),
)

// ─── Main screen ─────────────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SongListScreen(
    songs: List<Song>,
    onSongClick: (Song, Int) -> Unit,
    onNowPlayingClick: () -> Unit,
    onTogglePlay: () -> Unit,
    onNext: () -> Unit,
    onPrev: () -> Unit,
    progress: Int,
    duration: Int,
) {
    // ── State ────────────────────────────────────────────────────────────────
    var showMinibar     by remember { mutableStateOf(false) }
    var showSearchSheet by remember { mutableStateOf(false) }
    var activeNav       by remember { mutableIntStateOf(0) }

    // Minibar gestur swipe-down
    var minibarDrag      by remember { mutableFloatStateOf(0f) }
    var minibarDismissed by remember { mutableStateOf(false) }

    val accent     = MaterialTheme.colorScheme.primary
    val bg         = MaterialTheme.colorScheme.background
    val surface    = MaterialTheme.colorScheme.surface

    // Muncul minibar saat ada lagu
    LaunchedEffect(PlayerState.currentSong) {
        if (PlayerState.currentSong != null && !minibarDismissed) showMinibar = true
    }

    // ── SearchSheet (ModalBottomSheet) ────────────────────────────────────────
    if (showSearchSheet) {
        SearchSheet(songs = songs, onSongClick = { song, idx ->
            showSearchSheet = false
            onSongClick(song, idx)
        }, onDismiss = { showSearchSheet = false })
    }

    // ── Root ──────────────────────────────────────────────────────────────────
    Box(Modifier.fillMaxSize().background(bg)) {

        Column(Modifier.fillMaxSize()) {

            // Header
            Column(Modifier.padding(start = 20.dp, end = 16.dp, top = 52.dp, bottom = 4.dp)) {
                Text("🌿 Flora Music", fontSize = 26.sp, fontWeight = FontWeight.ExtraBold,
                     color = MaterialTheme.colorScheme.onSurface)
                Text("${songs.size} lagu", fontSize = 13.sp,
                     color = MaterialTheme.colorScheme.onSurfaceVariant)
            }

            // Song list — masing-masing lagu punya card sendiri
            LazyColumn(
                contentPadding  = PaddingValues(
                    start = 12.dp, end = 12.dp, top = 8.dp,
                    bottom = 160.dp   // ruang untuk bottom bar
                ),
                verticalArrangement = Arrangement.spacedBy(6.dp),
                modifier = Modifier.fillMaxSize(),
            ) {
                itemsIndexed(songs, key = { _, s -> s.id }) { index, song ->
                    SongCard(
                        song      = song,
                        isPlaying = song.id == PlayerState.currentSong?.id,
                        accent    = accent,
                        onClick   = { onSongClick(song, index) },
                    )
                }
            }
        }

        // ── Bottom overlay ────────────────────────────────────────────────────
        Column(
            modifier         = Modifier.align(Alignment.BottomCenter),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {

            // Minibar (slide-down dismiss)
            AnimatedVisibility(
                visible = showMinibar && PlayerState.currentSong != null,
                enter   = slideInVertically(spring(dampingRatio = Spring.DampingRatioMediumBouncy,
                                                    stiffness = Spring.StiffnessMediumLow)) { it }
                          + fadeIn(),
                exit    = slideOutVertically(tween(280)) { it } + fadeOut(tween(200)),
            ) {
                PlayerState.currentSong?.let { song ->
                    MiniBar(
                        song       = song,
                        accent     = accent,
                        progress   = progress,
                        duration   = duration,
                        onNext     = onNext,
                        onPrev     = onPrev,
                        onToggle   = onTogglePlay,
                        onClick    = onNowPlayingClick,
                        onDismiss  = {
                            showMinibar     = false
                            minibarDismissed = false
                        },
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                    )
                }
            }

            // Baris bawah: [Search] [NavPill] [NPBubble]
            Row(
                verticalAlignment     = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 12.dp, end = 12.dp, bottom = 28.dp, top = 4.dp),
            ) {
                // Search bubble
                SearchBubble(onClick = { showSearchSheet = true })

                // Navbar pill (scrollable, maks 3 tampil)
                NavPill(
                    items      = NAV_ITEMS,
                    activeIdx  = activeNav,
                    accentColor = accent,
                    onSelect   = { activeNav = it },
                    modifier   = Modifier.weight(1f),
                )

                // NP bubble — tampil hanya saat minibar tersembunyi
                AnimatedVisibility(
                    visible = !showMinibar && PlayerState.currentSong != null,
                    enter   = scaleIn(spring(dampingRatio = Spring.DampingRatioMediumBouncy,
                                             stiffness = Spring.StiffnessMedium))
                              + fadeIn(),
                    exit    = scaleOut(tween(150)) + fadeOut(tween(150)),
                ) {
                    PlayerState.currentSong?.let { song ->
                        NowPlayingBubble(
                            song     = song,
                            accent   = accent,
                            progress = progress,
                            duration = duration,
                            onClick  = {
                                minibarDismissed = false
                                showMinibar      = true
                            },
                        )
                    }
                }
            }
        }
    }
}

// ─── Song Card ───────────────────────────────────────────────────────────────
@Composable
fun SongCard(song: Song, isPlaying: Boolean, accent: Color, onClick: () -> Unit) {
    val borderColor = if (isPlaying) accent else Color.Transparent
    val cardBg      = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.55f)

    Surface(
        onClick = onClick,
        shape   = RoundedCornerShape(16.dp),
        color   = cardBg,
        border  = BorderStroke(
            width = if (isPlaying) 1.5.dp else 0.dp,
            color = borderColor,
        ),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(10.dp),
        ) {
            // Strip aksen kiri saat aktif
            AnimatedVisibility(visible = isPlaying) {
                Box(
                    modifier = Modifier
                        .width(3.dp)
                        .height(52.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(accent)
                        .padding(end = 4.dp),
                )
            }

            Spacer(Modifier.width(if (isPlaying) 8.dp else 0.dp))

            // Cover art
            AlbumArtThumb(song = song, size = 52)

            // Info
            Column(
                modifier = Modifier.weight(1f)
                    .padding(start = 12.dp, end = 8.dp),
            ) {
                Text(
                    text       = song.title,
                    fontSize   = 15.sp,
                    fontWeight = FontWeight.SemiBold,
                    color      = if (isPlaying) accent
                                 else MaterialTheme.colorScheme.onSurface,
                    maxLines   = 1,
                    overflow   = TextOverflow.Ellipsis,
                )
                Text(
                    text     = song.artist,
                    fontSize = 12.sp,
                    color    = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(top = 2.dp),
                )
            }

            // Duration
            Text(
                text     = song.durationText,
                fontSize = 11.sp,
                color    = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ─── MiniBar ─────────────────────────────────────────────────────────────────
@Composable
fun MiniBar(
    song: Song, accent: Color, progress: Int, duration: Int,
    onNext: () -> Unit, onPrev: () -> Unit, onToggle: () -> Unit,
    onClick: () -> Unit, onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    // Swipe-down dismiss gesture
    var offsetY by remember { mutableFloatStateOf(0f) }
    val animY   by animateFloatAsState(offsetY,
        spring(dampingRatio = Spring.DampingRatioMediumBouncy,
               stiffness = Spring.StiffnessMedium), label = "minibarY")

    // Spinning rotation saat playing
    val infiniteTransition = rememberInfiniteTransition(label = "spin")
    val rotation by infiniteTransition.animateFloat(
        initialValue   = 0f,
        targetValue    = 360f,
        animationSpec  = infiniteRepeatable(tween(6000, easing = LinearEasing)),
        label          = "rotation",
    )

    val progressFraction = if (duration > 0) progress.toFloat() / duration else 0f

    Box(modifier = modifier.offset(y = animY.dp)
        .pointerInput(Unit) {
            detectVerticalDragGestures(
                onVerticalDrag = { _, delta ->
                    if (offsetY + delta > 0) offsetY += delta * 0.5f
                },
                onDragEnd = {
                    if (offsetY > 60f) onDismiss()
                    else offsetY = 0f
                },
                onDragCancel = { offsetY = 0f },
            )
        }
    ) {
        Surface(
            shape   = RoundedCornerShape(24.dp),
            color   = accent,
            tonalElevation = 8.dp,
            modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
        ) {
            Column {
                // Konten utama
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(10.dp),
                ) {
                    // Cover art — spinning saat playing
                    Box(
                        modifier = Modifier
                            .size(52.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .rotate(if (PlayerState.isPlaying) rotation else 0f),
                    ) {
                        AsyncImage(
                            model              = song.albumArtUri,
                            contentDescription = null,
                            contentScale       = ContentScale.Crop,
                            modifier           = Modifier
                                .fillMaxSize()
                                .clip(RoundedCornerShape(12.dp))
                                .background(DynamicThemeHelper.colorForTitle(song.title)),
                        )
                    }

                    // Judul + artis
                    Column(
                        modifier = Modifier.weight(1f)
                            .padding(horizontal = 12.dp),
                    ) {
                        Text(song.title, fontSize = 14.sp, fontWeight = FontWeight.Bold,
                             color = Color.White, maxLines = 1, overflow = TextOverflow.Ellipsis)
                        Text(song.artist, fontSize = 12.sp,
                             color = Color.White.copy(alpha = 0.80f),
                             maxLines = 1, overflow = TextOverflow.Ellipsis)
                    }

                    // Kontrol
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        MiniCtrlBtn(icon = "⏮", size = 36, accent = accent, onClick = onPrev)
                        MiniCtrlBtn(icon = if (PlayerState.isPlaying) "⏸" else "▶",
                                    size = 42, accent = accent, primary = true, onClick = onToggle)
                        MiniCtrlBtn(icon = "⏭", size = 36, accent = accent, onClick = onNext)
                    }
                }

                // Progress bar tipis di bawah kontainer
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(3.dp)
                        .padding(horizontal = 12.dp)
                        .padding(bottom = 10.dp),
                ) {
                    Box(
                        modifier = Modifier.fillMaxSize()
                            .clip(RoundedCornerShape(2.dp))
                            .background(Color.White.copy(alpha = 0.25f)),
                    )
                    Box(
                        modifier = Modifier
                            .fillMaxHeight()
                            .fillMaxWidth(progressFraction)
                            .clip(RoundedCornerShape(2.dp))
                            .background(Color.White),
                    )
                }
                Spacer(Modifier.height(8.dp))
            }
        }
    }
}

@Composable
fun MiniCtrlBtn(
    icon: String, size: Int, accent: Color,
    primary: Boolean = false, onClick: () -> Unit,
) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(size.dp)
            .clip(CircleShape)
            .background(
                if (primary) Color.White.copy(alpha = 0.25f)
                else Color.White.copy(alpha = 0.12f)
            )
            .clickable(onClick = onClick),
    ) {
        Text(icon, fontSize = (size * 0.40).sp, color = Color.White)
    }
}

// ─── NavPill ─────────────────────────────────────────────────────────────────
@Composable
fun NavPill(
    items: List<NavItem>,
    activeIdx: Int,
    accentColor: Color,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    Surface(
        shape = RoundedCornerShape(50),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.90f),
        tonalElevation = 4.dp,
        modifier = modifier.height(52.dp),
    ) {
        LazyRow(
            verticalAlignment     = Alignment.CenterVertically,
            contentPadding        = PaddingValues(horizontal = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            itemsIndexed(items) { index, item ->
                val isActive = index == activeIdx
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .height(40.dp)
                        .clip(RoundedCornerShape(50))
                        .background(
                            if (isActive) accentColor.copy(alpha = 0.20f)
                            else Color.Transparent
                        )
                        .clickable { onSelect(index) }
                        .padding(horizontal = 10.dp),
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                    ) {
                        Text(item.icon, fontSize = 16.sp)
                        AnimatedVisibility(visible = isActive) {
                            Text(
                                text     = item.label,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                color    = accentColor,
                            )
                        }
                    }
                }
            }
        }
    }
}

// ─── Search Bubble ───────────────────────────────────────────────────────────
@Composable
fun SearchBubble(onClick: () -> Unit) {
    Surface(
        onClick       = onClick,
        shape         = CircleShape,
        color         = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.90f),
        tonalElevation = 4.dp,
        modifier      = Modifier.size(52.dp),
    ) {
        Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
            Icon(Icons.Default.Search, contentDescription = "Cari",
                 tint = MaterialTheme.colorScheme.onSurfaceVariant,
                 modifier = Modifier.size(22.dp))
        }
    }
}

// ─── Now-Playing Bubble ───────────────────────────────────────────────────────
@Composable
fun NowPlayingBubble(
    song: Song, accent: Color, progress: Int, duration: Int, onClick: () -> Unit,
) {
    val progressFraction = if (duration > 0) progress.toFloat() / duration else 0f
    val strokeWidth = 3.dp

    // Spinning rotation
    val infiniteTransition = rememberInfiniteTransition(label = "bubbleSpin")
    val rotation by infiniteTransition.animateFloat(
        0f, 360f,
        infiniteRepeatable(tween(6000, easing = LinearEasing)),
        label = "bubbleRot",
    )

    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier.size(52.dp).clickable(onClick = onClick),
    ) {
        // Ring progress melingkari bubble
        Canvas(modifier = Modifier.fillMaxSize()) {
            val s    = size.minDimension
            val sw   = strokeWidth.toPx()
            val rect = androidx.compose.ui.geometry.Rect(
                offset = Offset(sw / 2, sw / 2),
                size   = Size(s - sw, s - sw),
            )
            // Track
            drawArc(
                color       = accent.copy(alpha = 0.22f),
                startAngle  = -90f,
                sweepAngle  = 360f,
                useCenter   = false,
                topLeft     = rect.topLeft,
                size        = rect.size,
                style       = Stroke(width = sw, cap = StrokeCap.Round),
            )
            // Progress
            drawArc(
                color       = accent,
                startAngle  = -90f,
                sweepAngle  = 360f * progressFraction,
                useCenter   = false,
                topLeft     = rect.topLeft,
                size        = rect.size,
                style       = Stroke(width = sw, cap = StrokeCap.Round),
            )
        }

        // Cover art dalam lingkaran — spinning saat playing
        Box(
            modifier = Modifier
                .size(42.dp)
                .clip(CircleShape)
                .rotate(if (PlayerState.isPlaying) rotation else 0f),
        ) {
            AsyncImage(
                model              = song.albumArtUri,
                contentDescription = null,
                contentScale       = ContentScale.Crop,
                modifier           = Modifier
                    .fillMaxSize()
                    .clip(CircleShape)
                    .background(DynamicThemeHelper.colorForTitle(song.title)),
            )
        }
    }
}

// ─── Search BottomSheet ───────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchSheet(
    songs: List<Song>,
    onSongClick: (Song, Int) -> Unit,
    onDismiss: () -> Unit,
) {
    var query by remember { mutableStateOf("") }
    val filtered = remember(query, songs) {
        if (query.isBlank()) songs
        else songs.filter {
            it.title.contains(query, true) || it.artist.contains(query, true)
        }
    }
    val focus = LocalFocusManager.current
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState       = sheetState,
        containerColor   = MaterialTheme.colorScheme.surfaceVariant,
        shape            = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
    ) {
        Column(modifier = Modifier.fillMaxHeight(0.92f)) {
            Text("Cari Lagu", fontSize = 20.sp, fontWeight = FontWeight.ExtraBold,
                 color = MaterialTheme.colorScheme.onSurface,
                 modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp))

            OutlinedTextField(
                value         = query,
                onValueChange = { query = it },
                placeholder   = { Text("Judul, artis, album...") },
                leadingIcon   = { Icon(Icons.Default.Search, null) },
                trailingIcon  = {
                    if (query.isNotEmpty())
                        IconButton(onClick = { query = ""; focus.clearFocus() }) {
                            Icon(Icons.Default.Clear, null)
                        }
                },
                singleLine      = true,
                shape           = RoundedCornerShape(16.dp),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                keyboardActions = KeyboardActions(onSearch = { focus.clearFocus() }),
                modifier        = Modifier.fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
            )

            LazyColumn(
                contentPadding = PaddingValues(
                    start = 12.dp, end = 12.dp, top = 8.dp, bottom = 32.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                itemsIndexed(filtered, key = { _, s -> s.id }) { _, song ->
                    SongCard(
                        song      = song,
                        isPlaying = song.id == PlayerState.currentSong?.id,
                        accent    = MaterialTheme.colorScheme.primary,
                        onClick   = { onSongClick(song, songs.indexOf(song)) },
                    )
                }
            }
        }
    }
}

// ─── AlbumArtThumb (helper) ──────────────────────────────────────────────────
@Composable
fun AlbumArtThumb(song: Song, size: Int) {
    Box(
        modifier = Modifier.size(size.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(DynamicThemeHelper.colorForTitle(song.title)),
    ) {
        AsyncImage(
            model              = song.albumArtUri,
            contentDescription = null,
            contentScale       = ContentScale.Crop,
            modifier           = Modifier.fillMaxSize().clip(RoundedCornerShape(14.dp)),
        )
    }
}
KOTLIN

echo "  ✓ SongListScreen.kt"

# ─────────────────────────────────────────────────────────────────────────────
# Update FloraApp.kt — teruskan parameter baru ke SongListScreen
# ─────────────────────────────────────────────────────────────────────────────
cat > "$UI_DIR/FloraApp.kt" << 'KOTLIN'
package com.dioxd.floramusic.ui

import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song

@Composable
fun FloraApp(
    songs: List<Song>, onSongClick: (Song, Int) -> Unit,
    onTogglePlay: () -> Unit, onNext: () -> Unit, onPrev: () -> Unit,
    seekTo: (Int) -> Unit, progress: Int, duration: Int,
) {
    val nav = rememberNavController()

    NavHost(
        navController      = nav,
        startDestination   = "list",
        enterTransition    = { slideInVertically(tween(300)) { it } + fadeIn(tween(300)) },
        exitTransition     = { fadeOut(tween(200)) },
        popEnterTransition = { fadeIn(tween(200)) },
        popExitTransition  = { slideOutVertically(tween(300)) { it } + fadeOut(tween(300)) },
    ) {
        composable("list") {
            SongListScreen(
                songs             = songs,
                onSongClick       = { song, idx -> onSongClick(song, idx); nav.navigate("nowplaying") },
                onNowPlayingClick = { if (PlayerState.currentSong != null) nav.navigate("nowplaying") },
                onTogglePlay      = onTogglePlay,
                onNext            = onNext,
                onPrev            = onPrev,
                progress          = progress,
                duration          = duration,
            )
        }
        composable("nowplaying") {
            NowPlayingScreen(
                onBack       = { nav.popBackStack() },
                onNext       = onNext,
                onPrev       = onPrev,
                onTogglePlay = onTogglePlay,
                seekTo       = seekTo,
                progress     = progress,
                duration     = duration,
            )
        }
    }
}
KOTLIN

echo "  ✓ FloraApp.kt"

# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "✅ UI halaman utama selesai dirombak!"
echo ""
echo "Yang berubah:"
echo "  ✦ Song list → tiap lagu punya card sendiri"
echo "    - Outline aksen + strip kiri saat aktif"
echo "  ✦ MiniBar baru:"
echo "    - Background aksen, cover art spinning"
echo "    - Swipe-down → slide+bounce dismiss"
echo "    - Progress bar tipis di bawah kontainer"
echo "  ✦ Bottom row: [Search🔍] [NavPill] [NPBubble]"
echo "    - NavPill scrollable, maks tampil penuh"
echo "    - Search bubble → SearchSheet (ModalBottomSheet)"
echo "    - NP Bubble: circular progress + cover spinning"
echo "    - Minibar & NP bubble saling eksklusif"
echo "  ✦ FloraApp.kt diupdate (param baru SongListScreen)"
echo ""
echo "Jalankan:"
echo "  git add ."
echo "  git commit -m 'feat: rombak UI halaman utama'"
echo "  git pull --rebase && git push"
