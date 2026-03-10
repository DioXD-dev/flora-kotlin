#!/bin/bash
# Flora Music - Kotlin + Material You
# Setup script — jalankan di dalam folder repo kamu

echo "🌿 Membuat project Flora Music Kotlin..."

# ── Buat semua direktori ──────────────────────────────────────────────────────
mkdir -p app/src/main/java/com/dioxd/floramusic/{ui,data}
mkdir -p app/src/main/res/{layout,values,values-night,drawable}
mkdir -p app/src/main/res/mipmap-{hdpi,mdpi,xhdpi,xxhdpi,xxxhdpi}
mkdir -p gradle/wrapper
mkdir -p .github/workflows

echo "📁 Direktori siap"

# ── settings.gradle.kts ──────────────────────────────────────────────────────
cat > settings.gradle.kts << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "FloraMusic"
include(":app")
EOF

# ── build.gradle.kts (root) ───────────────────────────────────────────────────
cat > build.gradle.kts << 'EOF'
plugins {
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.23" apply false
}
EOF

# ── app/build.gradle.kts ─────────────────────────────────────────────────────
cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.dioxd.floramusic"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.dioxd.floramusic"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release { isMinifyEnabled = false }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = "17" }

    buildFeatures { viewBinding = true }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.activity:activity-ktx:1.9.0")
    implementation("com.github.bumptech.glide:glide:4.16.0")
}
EOF

# ── gradle/wrapper/gradle-wrapper.properties ──────────────────────────────────
cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.6-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# ── gradlew ───────────────────────────────────────────────────────────────────
cat > gradlew << 'EOF'
#!/bin/sh
PRG="$0"
while [ -h "$PRG" ]; do
  ls=$(ls -ld "$PRG")
  link=$(expr "$ls" : '.*-> \(.*\)$')
  if expr "$link" : '/.*' > /dev/null; then PRG="$link"
  else PRG=$(dirname "$PRG")/"$link"; fi
done
APP_HOME=$(cd "$(dirname "$PRG")" && pwd -P)
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'
CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar
if [ -n "$JAVA_HOME" ]; then JAVACMD="$JAVA_HOME/bin/java"
else JAVACMD="java"; fi
eval set -- $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS \"-Dorg.gradle.appname=$(basename $0)\" -classpath "\"$CLASSPATH\"" org.gradle.wrapper.GradleWrapperMain '"$@"'
exec "$JAVACMD" "$@"
EOF
chmod +x gradlew

# ── AndroidManifest.xml ───────────────────────────────────────────────────────
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
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

# ── Song.kt ───────────────────────────────────────────────────────────────────
cat > app/src/main/java/com/dioxd/floramusic/data/Song.kt << 'EOF'
package com.dioxd.floramusic.data

import android.net.Uri

data class Song(
    val id: Long,
    val title: String,
    val artist: String,
    val album: String,
    val duration: Long,
    val uri: Uri,
    val albumId: Long
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

# ── MusicRepository.kt ────────────────────────────────────────────────────────
cat > app/src/main/java/com/dioxd/floramusic/data/MusicRepository.kt << 'EOF'
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
            MediaStore.Audio.Media.ALBUM_ID
        )
        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0 AND ${MediaStore.Audio.Media.DURATION} > 30000"
        context.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection, selection, null,
            "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC"
        )?.use { cursor ->
            val idCol       = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleCol    = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistCol   = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumCol    = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationCol = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val albumIdCol  = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            while (cursor.moveToNext()) {
                val id = cursor.getLong(idCol)
                songs.add(Song(
                    id       = id,
                    title    = cursor.getString(titleCol) ?: "Unknown",
                    artist   = cursor.getString(artistCol)?.takeIf { it != "<unknown>" } ?: "Unknown Artist",
                    album    = cursor.getString(albumCol)?.takeIf { it != "<unknown>" } ?: "Unknown Album",
                    duration = cursor.getLong(durationCol),
                    uri      = Uri.withAppendedPath(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id.toString()),
                    albumId  = cursor.getLong(albumIdCol)
                ))
            }
        }
        return songs
    }
}
EOF

# ── SongAdapter.kt ────────────────────────────────────────────────────────────
cat > app/src/main/java/com/dioxd/floramusic/ui/SongAdapter.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ItemSongBinding

class SongAdapter(
    private val onSongClick: (Song, Int) -> Unit
) : ListAdapter<Song, SongAdapter.SongViewHolder>(DiffCallback) {

    var nowPlayingId: Long = -1L
        set(value) {
            val old = currentList.indexOfFirst { it.id == field }
            val new = currentList.indexOfFirst { it.id == value }
            field = value
            if (old >= 0) notifyItemChanged(old)
            if (new >= 0) notifyItemChanged(new)
        }

    inner class SongViewHolder(private val binding: ItemSongBinding)
        : RecyclerView.ViewHolder(binding.root) {
        fun bind(song: Song, position: Int) {
            binding.tvTitle.text    = song.title
            binding.tvArtist.text   = song.artist
            binding.tvDuration.text = song.durationText
            binding.root.isActivated = song.id == nowPlayingId
            Glide.with(binding.imgAlbumArt)
                .load(song.albumArtUri)
                .placeholder(R.drawable.ic_music_note)
                .error(R.drawable.ic_music_note)
                .transition(DrawableTransitionOptions.withCrossFade())
                .centerCrop()
                .into(binding.imgAlbumArt)
            binding.root.setOnClickListener { onSongClick(song, position) }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        SongViewHolder(ItemSongBinding.inflate(LayoutInflater.from(parent.context), parent, false))

    override fun onBindViewHolder(holder: SongViewHolder, position: Int) =
        holder.bind(getItem(position), position)

    companion object DiffCallback : DiffUtil.ItemCallback<Song>() {
        override fun areItemsTheSame(a: Song, b: Song) = a.id == b.id
        override fun areContentsTheSame(a: Song, b: Song) = a == b
    }
}
EOF

# ── MainActivity.kt ───────────────────────────────────────────────────────────
cat > app/src/main/java/com/dioxd/floramusic/ui/MainActivity.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.MusicRepository
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: SongAdapter
    private var mediaPlayer: MediaPlayer? = null
    private var songs: List<Song> = emptyList()
    private var currentIndex = -1

    private val permLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) loadSongs()
        else Toast.makeText(this, "Izin diperlukan untuk membaca musik 🎵", Toast.LENGTH_LONG).show()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        adapter = SongAdapter { song, index -> playSong(song, index) }
        binding.recyclerView.adapter = adapter
        binding.recyclerView.setHasFixedSize(true)
        binding.btnPlayPause.setOnClickListener {
            mediaPlayer?.let { if (it.isPlaying) pauseSong() else resumeSong() }
        }
        binding.btnNext.setOnClickListener { playNext() }
        binding.btnPrev.setOnClickListener { playPrev() }
        checkPermission()
    }

    private fun checkPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.READ_MEDIA_AUDIO else Manifest.permission.READ_EXTERNAL_STORAGE
        if (ContextCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED)
            loadSongs() else permLauncher.launch(perm)
    }

    private fun loadSongs() {
        songs = MusicRepository.getAllSongs(this)
        adapter.submitList(songs)
        binding.tvSongCount.text = "${songs.size} lagu"
    }

    private fun playSong(song: Song, index: Int) {
        currentIndex = index
        mediaPlayer?.release()
        mediaPlayer = MediaPlayer().apply {
            setDataSource(applicationContext, song.uri)
            prepare(); start()
            setOnCompletionListener { playNext() }
        }
        adapter.nowPlayingId = song.id
        binding.tvNowTitle.text  = song.title
        binding.tvNowArtist.text = song.artist
        binding.btnPlayPause.setIconResource(R.drawable.ic_pause)
        Glide.with(this).load(song.albumArtUri)
            .placeholder(R.drawable.ic_music_note).error(R.drawable.ic_music_note)
            .centerCrop().into(binding.imgNowArt)
    }

    private fun pauseSong()  { mediaPlayer?.pause(); binding.btnPlayPause.setIconResource(R.drawable.ic_play) }
    private fun resumeSong() { mediaPlayer?.start(); binding.btnPlayPause.setIconResource(R.drawable.ic_pause) }
    private fun playNext() { if (songs.isEmpty()) return; val i = (currentIndex + 1) % songs.size; playSong(songs[i], i) }
    private fun playPrev() { if (songs.isEmpty()) return; val i = if (currentIndex <= 0) songs.size - 1 else currentIndex - 1; playSong(songs[i], i) }

    override fun onDestroy() { super.onDestroy(); mediaPlayer?.release() }
}
EOF

# ── activity_main.xml ─────────────────────────────────────────────────────────
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?attr/colorSurface">

    <com.google.android.material.appbar.AppBarLayout
        android:id="@+id/appBarLayout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content">
        <com.google.android.material.appbar.MaterialToolbar
            android:id="@+id/toolbar"
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            app:title="🌿 Flora Music"
            app:titleTextAppearance="@style/TextAppearance.Material3.HeadlineSmall"
            android:background="?attr/colorSurface" />
        <TextView
            android:id="@+id/tvSongCount"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Memuat lagu..."
            android:textAppearance="@style/TextAppearance.Material3.BodySmall"
            android:textColor="?attr/colorOnSurfaceVariant"
            android:paddingStart="20dp"
            android:paddingEnd="20dp"
            android:paddingBottom="12dp" />
    </com.google.android.material.appbar.AppBarLayout>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/recyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:clipToPadding="false"
        android:paddingBottom="100dp"
        app:layout_behavior="@string/appbar_scrolling_view_behavior"
        app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

    <com.google.android.material.card.MaterialCardView
        android:id="@+id/playerCard"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:layout_margin="12dp"
        app:cardCornerRadius="20dp"
        app:cardElevation="4dp"
        app:cardBackgroundColor="?attr/colorSecondaryContainer">
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:padding="12dp"
            android:gravity="center_vertical">
            <ImageView
                android:id="@+id/imgNowArt"
                android:layout_width="48dp"
                android:layout_height="48dp"
                android:scaleType="centerCrop"
                android:background="@drawable/rounded_art"
                android:clipToOutline="true"
                android:src="@drawable/ic_music_note" />
            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical"
                android:layout_marginStart="12dp"
                android:layout_marginEnd="8dp">
                <TextView
                    android:id="@+id/tvNowTitle"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:text="Tidak ada lagu"
                    android:textAppearance="@style/TextAppearance.Material3.BodyMedium"
                    android:textStyle="bold"
                    android:textColor="?attr/colorOnSecondaryContainer"
                    android:maxLines="1"
                    android:ellipsize="end" />
                <TextView
                    android:id="@+id/tvNowArtist"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:text="—"
                    android:textAppearance="@style/TextAppearance.Material3.BodySmall"
                    android:textColor="?attr/colorOnSecondaryContainer"
                    android:maxLines="1"
                    android:ellipsize="end" />
            </LinearLayout>
            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnPrev"
                style="@style/Widget.Material3.Button.IconButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                app:icon="@drawable/ic_skip_prev" />
            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnPlayPause"
                style="@style/Widget.Material3.Button.IconButton.Filled.Tonal"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                app:icon="@drawable/ic_play" />
            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnNext"
                style="@style/Widget.Material3.Button.IconButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                app:icon="@drawable/ic_skip_next" />
        </LinearLayout>
    </com.google.android.material.card.MaterialCardView>

</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

# ── item_song.xml ─────────────────────────────────────────────────────────────
cat > app/src/main/res/layout/item_song.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginHorizontal="12dp"
    android:layout_marginVertical="3dp"
    app:cardCornerRadius="16dp"
    app:cardElevation="0dp"
    app:cardBackgroundColor="?attr/colorSurfaceVariant"
    android:foreground="?attr/selectableItemBackground">
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="12dp"
        android:gravity="center_vertical">
        <ImageView
            android:id="@+id/imgAlbumArt"
            android:layout_width="52dp"
            android:layout_height="52dp"
            android:scaleType="centerCrop"
            android:background="@drawable/rounded_art"
            android:clipToOutline="true"
            android:src="@drawable/ic_music_note" />
        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:orientation="vertical"
            android:layout_marginStart="12dp">
            <TextView
                android:id="@+id/tvTitle"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.Material3.BodyLarge"
                android:textStyle="bold"
                android:textColor="?attr/colorOnSurface"
                android:maxLines="1"
                android:ellipsize="end" />
            <TextView
                android:id="@+id/tvArtist"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.Material3.BodySmall"
                android:textColor="?attr/colorOnSurfaceVariant"
                android:maxLines="1"
                android:ellipsize="end"
                android:layout_marginTop="2dp" />
        </LinearLayout>
        <TextView
            android:id="@+id/tvDuration"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textAppearance="@style/TextAppearance.Material3.LabelSmall"
            android:textColor="?attr/colorOnSurfaceVariant"
            android:layout_marginStart="8dp" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ── colors.xml ────────────────────────────────────────────────────────────────
cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="seed_primary">#386A20</color>
    <color name="seed_on_primary">#FFFFFF</color>
    <color name="seed_primary_container">#B2F397</color>
    <color name="seed_on_primary_container">#062100</color>
    <color name="seed_secondary">#54634D</color>
    <color name="seed_secondary_container">#D7E8CC</color>
    <color name="seed_on_secondary_container">#121F0E</color>
    <color name="seed_surface">#FDFDF6</color>
    <color name="seed_surface_variant">#DFE4D8</color>
    <color name="seed_on_surface">#1A1C18</color>
    <color name="seed_on_surface_variant">#43483E</color>
    <color name="seed_primary_dark">#97D77E</color>
    <color name="seed_on_primary_dark">#0D3900</color>
    <color name="seed_primary_container_dark">#245108</color>
    <color name="seed_on_primary_container_dark">#B2F397</color>
    <color name="seed_secondary_dark">#BBCBB5</color>
    <color name="seed_secondary_container_dark">#3C4B36</color>
    <color name="seed_on_secondary_container_dark">#D7E8CC</color>
    <color name="seed_surface_dark">#1A1C18</color>
    <color name="seed_surface_variant_dark">#43483E</color>
    <color name="seed_on_surface_dark">#E2E3DC</color>
    <color name="seed_on_surface_variant_dark">#C3C8BC</color>
</resources>
EOF

# ── strings.xml ───────────────────────────────────────────────────────────────
cat > app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Flora Music</string>
</resources>
EOF

# ── themes.xml (light) ────────────────────────────────────────────────────────
cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.FloraMusic" parent="Theme.Material3.DayNight.NoActionBar">
        <item name="colorPrimary">@color/seed_primary</item>
        <item name="colorOnPrimary">@color/seed_on_primary</item>
        <item name="colorPrimaryContainer">@color/seed_primary_container</item>
        <item name="colorOnPrimaryContainer">@color/seed_on_primary_container</item>
        <item name="colorSecondary">@color/seed_secondary</item>
        <item name="colorSecondaryContainer">@color/seed_secondary_container</item>
        <item name="colorOnSecondaryContainer">@color/seed_on_secondary_container</item>
        <item name="colorSurface">@color/seed_surface</item>
        <item name="colorSurfaceVariant">@color/seed_surface_variant</item>
        <item name="colorOnSurface">@color/seed_on_surface</item>
        <item name="colorOnSurfaceVariant">@color/seed_on_surface_variant</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/transparent</item>
        <item name="android:windowLightStatusBar">true</item>
    </style>
</resources>
EOF

# ── themes.xml (night/dark) ───────────────────────────────────────────────────
cat > app/src/main/res/values-night/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.FloraMusic" parent="Theme.Material3.DayNight.NoActionBar">
        <item name="colorPrimary">@color/seed_primary_dark</item>
        <item name="colorOnPrimary">@color/seed_on_primary_dark</item>
        <item name="colorPrimaryContainer">@color/seed_primary_container_dark</item>
        <item name="colorOnPrimaryContainer">@color/seed_on_primary_container_dark</item>
        <item name="colorSecondary">@color/seed_secondary_dark</item>
        <item name="colorSecondaryContainer">@color/seed_secondary_container_dark</item>
        <item name="colorOnSecondaryContainer">@color/seed_on_secondary_container_dark</item>
        <item name="colorSurface">@color/seed_surface_dark</item>
        <item name="colorSurfaceVariant">@color/seed_surface_variant_dark</item>
        <item name="colorOnSurface">@color/seed_on_surface_dark</item>
        <item name="colorOnSurfaceVariant">@color/seed_on_surface_variant_dark</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/transparent</item>
        <item name="android:windowLightStatusBar">false</item>
    </style>
</resources>
EOF

# ── Drawables ─────────────────────────────────────────────────────────────────
cat > app/src/main/res/drawable/rounded_art.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <corners android:radius="12dp" />
    <solid android:color="#22000000" />
</shape>
EOF

cat > app/src/main/res/drawable/ic_music_note.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSurfaceVariant">
    <path android:fillColor="@android:color/white"
        android:pathData="M12,3v10.55c-0.59,-0.34 -1.27,-0.55 -2,-0.55c-2.21,0 -4,1.79 -4,4s1.79,4 4,4 4,-1.79 4,-4V7h4V3h-6z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_play.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSecondaryContainer">
    <path android:fillColor="@android:color/white" android:pathData="M8,5v14l11,-7z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_pause.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSecondaryContainer">
    <path android:fillColor="@android:color/white" android:pathData="M6,19h4V5H6v14zm8,-14v14h4V5h-4z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_skip_next.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSecondaryContainer">
    <path android:fillColor="@android:color/white" android:pathData="M6,18l8.5,-6L6,6v12zM16,6v12h2V6h-2z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_skip_prev.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSecondaryContainer">
    <path android:fillColor="@android:color/white" android:pathData="M6,6h2v12H6zm3.5,6l8.5,6V6z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_launcher_foreground.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#4a9460" android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#FFFFFF"
        android:pathData="M54,25v28c-1.64,-0.94 -3.53,-1.53 -5.56,-1.53C42.56,51.47 38,56.03 38,61.91S42.56,72.35 48.44,72.35s10.44,-4.56 10.44,-10.44V36.11H69.89V25H54z"/>
</vector>
EOF

# ── Launcher icons (adaptive) ─────────────────────────────────────────────────
LAUNCHER_XML='<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/seed_primary_container" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>'

for d in hdpi mdpi xhdpi xxhdpi xxxhdpi; do
    echo "$LAUNCHER_XML" > app/src/main/res/mipmap-$d/ic_launcher.xml
    echo "$LAUNCHER_XML" > app/src/main/res/mipmap-$d/ic_launcher_round.xml
done

# ── GitHub Actions workflow ───────────────────────────────────────────────────
cat > .github/workflows/build.yml << 'EOF'
name: Build APK

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v3

      - name: Make gradlew executable
        run: chmod +x gradlew

      - name: Build Debug APK
        run: ./gradlew assembleDebug

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: Flora-kotlin-debug
          path: app/build/outputs/apk/debug/*.apk
EOF

echo ""
echo "✅ Semua file berhasil dibuat!"
echo ""
echo "Sekarang jalankan:"
echo "  git add ."
echo "  git commit -m 'init: Flora Music Kotlin + Material You'"
echo "  git push"
