#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║  Flora Music — Complete Clean Rebuild                   ║
# ║  Jetpack Compose + Material3 + GitHub Actions           ║
# ╚══════════════════════════════════════════════════════════╝
# Jalankan di: ~/flora-kotlin

set -e
echo "🌿 Flora Music — Membangun ulang dari nol..."
echo ""

if [ ! -f "app/build.gradle.kts" ]; then
    echo "❌ Jalankan di dalam folder ~/flora-kotlin!"
    exit 1
fi

ROOT="app/src/main"
JAVA="$ROOT/java/com/dioxd/floramusic"
UI="$JAVA/ui"
DATA="$JAVA/data"
THEME="$UI/theme"
RES="$ROOT/res"

mkdir -p "$UI" "$DATA" "$THEME" \
         "$RES/values" "$RES/values-night" \
         "$RES/drawable" "$RES/mipmap-hdpi" \
         "$RES/mipmap-mdpi" "$RES/mipmap-xhdpi" \
         "$RES/mipmap-xxhdpi" "$RES/mipmap-xxxhdpi" \
         ".github/workflows"

# ─────────────────────────────────────────────────────────────────────────────
echo "📦 [1/11] build.gradle.kts..."
# ─────────────────────────────────────────────────────────────────────────────
cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace   = "com.dioxd.floramusic"
    compileSdk  = 34

    defaultConfig {
        applicationId = "com.dioxd.floramusic"
        minSdk        = 26
        targetSdk     = 34
        versionCode   = 1
        versionName   = "1.0"
    }

    buildTypes {
        release { isMinifyEnabled = false }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = "17" }

    buildFeatures { compose = true }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }
}

dependencies {
    // Compose BOM — versi dikunci, semua lib konsisten
    val bom = platform("androidx.compose:compose-bom:2024.09.00")
    implementation(bom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.animation:animation")
    implementation("androidx.compose.foundation:foundation")
    debugImplementation("androidx.compose.ui:ui-tooling")

    // AndroidX
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.5")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.5")
    implementation("androidx.navigation:navigation-compose:2.8.1")

    // Image loading
    implementation("io.coil-kt:coil-compose:2.7.0")

    // Palette — extract warna dari album art
    implementation("androidx.palette:palette-ktx:1.0.0")

    // Blur
    implementation("jp.wasabeef:blurry:4.0.1")
}
EOF
echo "  ✓ build.gradle.kts"

# ─────────────────────────────────────────────────────────────────────────────
echo "⚙️  [2/11] settings.gradle.kts..."
# ─────────────────────────────────────────────────────────────────────────────
cat > settings.gradle.kts << 'EOF'
pluginManagement {
    repositories {
        google(); mavenCentral(); gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google(); mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
rootProject.name = "FloraMusic"
include(":app")
EOF
echo "  ✓ settings.gradle.kts"

# ─────────────────────────────────────────────────────────────────────────────
echo "📄 [3/11] AndroidManifest.xml..."
# ─────────────────────────────────────────────────────────────────────────────
cat > "$ROOT/AndroidManifest.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="Flora Music"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.FloraMusic">

        <activity
            android:name=".ui.MainActivity"
            android:exported="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF
echo "  ✓ AndroidManifest.xml"

# ─────────────────────────────────────────────────────────────────────────────
echo "🎨 [4/11] Resources (themes, colors, launcher icons)..."
# ─────────────────────────────────────────────────────────────────────────────
cat > "$RES/values/themes.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.FloraMusic" parent="Theme.Material3.DayNight.NoActionBar" />
</resources>
EOF

cat > "$RES/values/strings.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Flora Music</string>
</resources>
EOF

# Launcher icon foreground SVG → VectorDrawable
cat > "$RES/drawable/ic_launcher_foreground.xml" << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#4a9460"
        android:pathData="M0,0h108v108H0z"/>
    <path android:fillColor="#FFFFFF"
        android:pathData="M54,25v28c-1.64,-0.94 -3.53,-1.53 -5.56,-1.53C42.56,51.47 38,56.03 38,61.91S42.56,72.35 48.44,72.35s10.44,-4.56 10.44,-10.44V36.11H69.89V25H54z"/>
</vector>
EOF

LAUNCHER_XML='<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/white"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>'
for d in hdpi mdpi xhdpi xxhdpi xxxhdpi; do
    echo "$LAUNCHER_XML" > "$RES/mipmap-$d/ic_launcher.xml"
    echo "$LAUNCHER_XML" > "$RES/mipmap-$d/ic_launcher_round.xml"
done
echo "  ✓ Themes, strings, launcher icons"

# ─────────────────────────────────────────────────────────────────────────────
echo "💾 [5/11] Data layer (Song, MusicRepository, PlayerState)..."
# ─────────────────────────────────────────────────────────────────────────────
cat > "$DATA/Song.kt" << 'EOF'
package com.dioxd.floramusic.data

import android.net.Uri

data class Song(
    val id:       Long,
    val title:    String,
    val artist:   String,
    val album:    String,
    val duration: Long,
    val uri:      Uri,
    val albumId:  Long,
) {
    val durationText: String get() {
        val m = duration / 1000 / 60
        val s = (duration / 1000) % 60
        return "%d:%02d".format(m, s)
    }
    val albumArtUri: Uri get() =
        Uri.parse("content://media/external/audio/albumart/$albumId")
}
EOF

cat > "$DATA/MusicRepository.kt" << 'EOF'
package com.dioxd.floramusic.data

import android.content.Context
import android.net.Uri
import android.provider.MediaStore

object MusicRepository {
    fun getAllSongs(context: Context): List<Song> {
        val songs = mutableListOf<Song>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ALBUM_ID,
        )
        val selection =
            "${MediaStore.Audio.Media.IS_MUSIC} != 0 " +
            "AND ${MediaStore.Audio.Media.DURATION} > 30000"

        context.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection, selection, null,
            "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC",
        )?.use { c ->
            val iId  = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val iTit = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val iArt = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val iAlb = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val iDur = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val iAid = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            while (c.moveToNext()) {
                val id = c.getLong(iId)
                songs += Song(
                    id       = id,
                    title    = c.getString(iTit) ?: "Unknown",
                    artist   = c.getString(iArt)?.takeIf { it != "<unknown>" } ?: "Unknown Artist",
                    album    = c.getString(iAlb)?.takeIf { it != "<unknown>" } ?: "Unknown Album",
                    duration = c.getLong(iDur),
                    uri      = Uri.withAppendedPath(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id.toString()),
                    albumId  = c.getLong(iAid),
                )
            }
        }
        return songs
    }
}
EOF

cat > "$DATA/PlayerState.kt" << 'EOF'
package com.dioxd.floramusic.data

import android.media.MediaPlayer
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

object PlayerState {
    var songs:        List<Song>   by mutableStateOf(emptyList())
    var currentIndex: Int          by mutableIntStateOf(-1)
    var isPlaying:    Boolean      by mutableStateOf(false)
    var shuffle:      Boolean      by mutableStateOf(false)
    var repeat:       Boolean      by mutableStateOf(false)
    var progress:     Int          by mutableIntStateOf(0)
    var duration:     Int          by mutableIntStateOf(0)

    val currentSong: Song? get() = songs.getOrNull(currentIndex)

    var mediaPlayer: MediaPlayer? = null
}
EOF
echo "  ✓ Song, MusicRepository, PlayerState"

# ─────────────────────────────────────────────────────────────────────────────
echo "🖌️  [6/11] Theme (FloraTheme + DynamicThemeHelper)..."
# ─────────────────────────────────────────────────────────────────────────────
cat > "$THEME/FloraTheme.kt" << 'EOF'
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
EOF

# DynamicThemeHelper — placeholder warna album art
cat > "$UI/DynamicThemeHelper.kt" << 'EOF'
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
EOF
echo "  ✓ FloraTheme, DynamicThemeHelper"

# ─────────────────────────────────────────────────────────────────────────────
echo "📋 [7/11] SongListScreen.kt..."
# ─────────────────────────────────────────────────────────────────────────────
cat > "$UI/SongListScreen.kt" << 'EOF'
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
EOF
echo "  ✓ SongListScreen.kt"

# ─────────────────────────────────────────────────────────────────────────────
echo "🎵 [8/11] NowPlayingScreen.kt..."
# ─────────────────────────────────────────────────────────────────────────────
cat > "$UI/NowPlayingScreen.kt" << 'EOF'
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
EOF
echo "  ✓ NowPlayingScreen.kt"

# ─────────────────────────────────────────────────────────────────────────────
echo "🧭 [9/11] FloraApp.kt + MainActivity.kt..."
# ─────────────────────────────────────────────────────────────────────────────
cat > "$UI/FloraApp.kt" << 'EOF'
package com.dioxd.floramusic.ui

import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song

@Composable
fun FloraApp(
    songs:        List<Song>,
    onSongClick:  (Song, Int) -> Unit,
    onTogglePlay: () -> Unit,
    onNext:       () -> Unit,
    onPrev:       () -> Unit,
    seekTo:       (Int) -> Unit,
    progress:     Int,
    duration:     Int,
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
                onSongClick       = { song, idx ->
                    onSongClick(song, idx)
                    nav.navigate("nowplaying")
                },
                onNowPlayingClick = {
                    if (PlayerState.currentSong != null) nav.navigate("nowplaying")
                },
                onTogglePlay = onTogglePlay,
                onNext       = onNext,
                onPrev       = onPrev,
                progress     = progress,
                duration     = duration,
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
EOF

cat > "$UI/MainActivity.kt" << 'EOF'
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.core.content.ContextCompat
import com.dioxd.floramusic.data.MusicRepository
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.ui.theme.FloraTheme

class MainActivity : ComponentActivity() {

    private var songs    by mutableStateOf(emptyList<Song>())
    private var progress by mutableIntStateOf(0)
    private var duration by mutableIntStateOf(0)

    private val handler = Handler(Looper.getMainLooper())
    private val progressUpdater = object : Runnable {
        override fun run() {
            PlayerState.mediaPlayer?.let {
                progress = it.currentPosition
                duration = it.duration
            }
            handler.postDelayed(this, 500)
        }
    }

    private val permLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted -> if (granted) loadSongs() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            FloraTheme {
                FloraApp(
                    songs        = songs,
                    onSongClick  = ::playSong,
                    onTogglePlay = ::togglePlay,
                    onNext       = ::playNext,
                    onPrev       = ::playPrev,
                    seekTo       = ::seekTo,
                    progress     = progress,
                    duration     = duration,
                )
            }
        }

        checkPermission()
        handler.post(progressUpdater)
    }

    private fun checkPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.READ_MEDIA_AUDIO
        else
            Manifest.permission.READ_EXTERNAL_STORAGE

        if (ContextCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED)
            loadSongs()
        else
            permLauncher.launch(perm)
    }

    private fun loadSongs() {
        songs = MusicRepository.getAllSongs(this)
        PlayerState.songs = songs
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
                else playNext()
            }
        }
        PlayerState.isPlaying = true
    }

    private fun togglePlay() {
        PlayerState.mediaPlayer?.let {
            if (it.isPlaying) { it.pause(); PlayerState.isPlaying = false }
            else              { it.start(); PlayerState.isPlaying = true  }
        }
    }

    private fun playNext() {
        val s = PlayerState.songs
        if (s.isEmpty()) return
        val next = if (PlayerState.shuffle)
            (0 until s.size).random()
        else
            (PlayerState.currentIndex + 1) % s.size
        playSong(s[next], next)
    }

    private fun playPrev() {
        val s = PlayerState.songs
        if (s.isEmpty()) return
        val prev = if (PlayerState.currentIndex <= 0) s.size - 1
                   else PlayerState.currentIndex - 1
        playSong(s[prev], prev)
    }

    private fun seekTo(ms: Int) {
        PlayerState.mediaPlayer?.seekTo(ms)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(progressUpdater)
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = null
    }
}
EOF
echo "  ✓ FloraApp.kt, MainActivity.kt"

# ─────────────────────────────────────────────────────────────────────────────
echo "🔨 [10/11] gradle.properties..."
# ─────────────────────────────────────────────────────────────────────────────
cat > gradle.properties << 'EOF'
android.useAndroidX=true
android.enableJetifier=true
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m
kotlin.code.style=official
EOF
echo "  ✓ gradle.properties"

# ─────────────────────────────────────────────────────────────────────────────
echo "🤖 [11/11] GitHub Actions workflow..."
# ─────────────────────────────────────────────────────────────────────────────
cat > .github/workflows/build.yml << 'EOF'
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - uses: gradle/actions/setup-gradle@v3

      - name: Download Gradle wrapper
        run: |
          wget -q https://services.gradle.org/distributions/gradle-8.6-bin.zip
          unzip -q gradle-8.6-bin.zip -d /tmp/gradle
          /tmp/gradle/gradle-8.6/bin/gradle wrapper
          chmod +x gradlew

      - name: Build Debug APK
        run: ./gradlew assembleDebug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: flora-debug
          path: app/build/outputs/apk/debug/*.apk
EOF
echo "  ✓ build.yml"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  ✅ Rebuild selesai! Semua file sudah ditulis.  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Sekarang jalankan:"
echo "  git add ."
echo "  git commit -m 'rebuild: Flora Music Compose - clean from scratch'"
echo "  git pull --rebase && git push"
