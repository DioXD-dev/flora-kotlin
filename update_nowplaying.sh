#!/bin/bash
# Flora Music - Update NowPlaying Screen Only
# Jalankan di dalam folder ~/flora-kotlin

echo "🎵 Mengupdate NowPlaying screen..."

mkdir -p app/src/main/res/{layout,drawable,anim}
mkdir -p app/src/main/java/com/dioxd/floramusic/ui

# ── DEPENDENCIES - tambah Palette & Blurry ───────────────────────────────────
# Ganti app/build.gradle.kts dependencies section
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

    // Palette API — extract dominant color dari album art
    implementation("androidx.palette:palette-ktx:1.0.0")

    // Blur effect
    implementation("jp.wasabeef:blurry:4.0.1")
}
EOF

# ── DRAWABLES ─────────────────────────────────────────────────────────────────

# Gradient overlay atas (untuk status bar)
cat > app/src/main/res/drawable/gradient_top.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:startColor="#CC000000"
        android:endColor="#00000000"
        android:angle="270" />
</shape>
EOF

# Gradient overlay bawah (untuk konten)
cat > app/src/main/res/drawable/gradient_bottom.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:startColor="#00000000"
        android:endColor="#E6000000"
        android:angle="270" />
</shape>
EOF

# Background pill untuk shortcut
cat > app/src/main/res/drawable/bg_pill.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="100dp" />
    <solid android:color="#33FFFFFF" />
</shape>
EOF

# Background pill aktif
cat > app/src/main/res/drawable/bg_pill_active.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="100dp" />
    <solid android:color="#88FFFFFF" />
</shape>
EOF

# Background tombol bulat (prev/next)
cat > app/src/main/res/drawable/bg_btn_circle.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#22FFFFFF" />
</shape>
EOF

# Background tombol play besar
cat > app/src/main/res/drawable/bg_play_big.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#CCFFFFFF" />
</shape>
EOF

# Album art rounded square
cat > app/src/main/res/drawable/bg_album_rounded.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="20dp" />
    <solid android:color="#44FFFFFF" />
</shape>
EOF

# Settings icon
cat > app/src/main/res/drawable/ic_settings.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M19.14,12.94c0.04,-0.3 0.06,-0.61 0.06,-0.94c0,-0.32 -0.02,-0.64 -0.07,-0.94l2.03,-1.58c0.18,-0.14 0.23,-0.41 0.12,-0.61l-1.92,-3.32c-0.12,-0.22 -0.37,-0.29 -0.59,-0.22l-2.39,0.96c-0.5,-0.38 -1.03,-0.7 -1.62,-0.94L14.4,2.81c-0.04,-0.24 -0.24,-0.41 -0.48,-0.41h-3.84c-0.24,0 -0.43,0.17 -0.47,0.41L9.25,5.35C8.66,5.59 8.12,5.92 7.63,6.29L5.24,5.33c-0.22,-0.08 -0.47,0 -0.59,0.22L2.74,8.87C2.62,9.08 2.66,9.34 2.86,9.48l2.03,1.58C4.84,11.36 4.8,11.69 4.8,12s0.02,0.64 0.07,0.94l-2.03,1.58c-0.18,0.14 -0.23,0.41 -0.12,0.61l1.92,3.32c0.12,0.22 0.37,0.29 0.59,0.22l2.39,-0.96c0.5,0.38 1.03,0.7 1.62,0.94l0.36,2.54c0.05,0.24 0.24,0.41 0.48,0.41h3.84c0.24,0 0.44,-0.17 0.47,-0.41l0.36,-2.54c0.59,-0.24 1.13,-0.56 1.62,-0.94l2.39,0.96c0.22,0.08 0.47,0 0.59,-0.22l1.92,-3.32c0.12,-0.22 0.07,-0.47 -0.12,-0.61L19.14,12.94zM12,15.6c-1.98,0 -3.6,-1.62 -3.6,-3.6s1.62,-3.6 3.6,-3.6s3.6,1.62 3.6,3.6S13.98,15.6 12,15.6z"/>
</vector>
EOF

# Back arrow icon
cat > app/src/main/res/drawable/ic_arrow_back.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M20,11H7.83l5.59,-5.59L12,4l-8,8 8,8 1.41,-1.41L7.83,13H20v-2z"/>
</vector>
EOF

# Heart icon (like)
cat > app/src/main/res/drawable/ic_heart.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M16.5,3c-1.74,0 -3.41,0.81 -4.5,2.09C10.91,3.81 9.24,3 7.5,3 4.42,3 2,5.42 2,8.5c0,3.78 3.4,6.86 8.55,11.54L12,21.35l1.45,-1.32C18.6,15.36 22,12.28 22,8.5 22,5.42 19.58,3 16.5,3zM12.1,18.55l-0.1,0.1 -0.1,-0.1C7.14,14.24 4,11.39 4,8.5 4,6.5 5.5,5 7.5,5c1.54,0 3.04,0.99 3.57,2.36h1.87C13.46,5.99 14.96,5 16.5,5c2,0 3.5,1.5 3.5,3.5 0,2.89 -3.14,5.74 -8,10.05z"/>
</vector>
EOF

# Queue icon
cat > app/src/main/res/drawable/ic_queue.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="20dp" android:height="20dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M15,6H3v2h12V6zM15,10H3v2h12v-2zM3,16h8v-2H3v2zM17,6v8.18C16.69,14.07 16.35,14 16,14c-1.66,0 -3,1.34 -3,3s1.34,3 3,3 3,-1.34 3,-3V8h3V6h-5z"/>
</vector>
EOF

# Lyrics icon
cat > app/src/main/res/drawable/ic_lyrics.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="20dp" android:height="20dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M12,3c-4.97,0 -9,4.03 -9,9v7c0,1.1 0.9,2 2,2h4v-8H5v-1c0,-3.87 3.13,-7 7,-7s7,3.13 7,7v1h-4v8h4c1.1,0 2,-0.9 2,-2v-7c0,-4.97 -4.03,-9 -9,-9z"/>
</vector>
EOF

# Timer icon
cat > app/src/main/res/drawable/ic_timer.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="20dp" android:height="20dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M15,1H9v2h6V1zM11,14h2V8h-2v6zM19.03,7.39l1.42,-1.42c-0.43,-0.51 -0.9,-0.99 -1.41,-1.41l-1.42,1.42C16.07,4.74 14.12,4 12,4c-4.97,0 -9,4.03 -9,9s4.02,9 9,9 9,-4.03 9,-9c0,-2.12 -0.74,-4.07 -1.97,-5.61zM12,20c-3.87,0 -7,-3.13 -7,-7s3.13,-7 7,-7 7,3.13 7,7 -3.13,7 -7,7z"/>
</vector>
EOF

# Shuffle icon
cat > app/src/main/res/drawable/ic_shuffle.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="20dp" android:height="20dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M10.59,9.17L5.41,4 4,5.41l5.17,5.17 1.42,-1.41zM14.5,4l2.04,2.04L4,18.59 5.41,20 17.96,7.46 20,9.5V4h-5.5zM14.83,13.41l-1.41,1.41 3.13,3.13L14.5,20H20v-5.5l-2.04,2.04 -3.13,-3.13z"/>
</vector>
EOF

# Repeat icon
cat > app/src/main/res/drawable/ic_repeat.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="20dp" android:height="20dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M7,7h10v3l4,-4 -4,-4v3H5v6h2V7zM17,17H7v-3l-4,4 4,4v-3h12v-6h-2v4z"/>
</vector>
EOF

# Play/Pause icons (dark tint for use on white bg)
cat > app/src/main/res/drawable/ic_play_dark.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="36dp" android:height="36dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#1a1a1a"
        android:pathData="M8,5v14l11,-7z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_pause_dark.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="36dp" android:height="36dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#1a1a1a"
        android:pathData="M6,19h4V5H6v14zm8,-14v14h4V5h-4z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_skip_prev_white.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="30dp" android:height="30dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M6,6h2v12H6zm3.5,6l8.5,6V6z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_skip_next_white.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="30dp" android:height="30dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="#FFFFFF">
    <path android:fillColor="@android:color/white"
        android:pathData="M6,18l8.5,-6L6,6v12zM16,6v12h2V6h-2z"/>
</vector>
EOF

# ── LAYOUT: activity_now_playing.xml ─────────────────────────────────────────
cat > app/src/main/res/layout/activity_now_playing.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#1a1a1a">

    <!-- Blurred background album art -->
    <ImageView
        android:id="@+id/imgBgBlur"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:scaleType="centerCrop"
        android:alpha="0.6" />

    <!-- Gradient overlay bottom (gelap di bawah) -->
    <View
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@drawable/gradient_bottom" />

    <!-- Gradient overlay top (gelap di atas untuk status bar) -->
    <View
        android:layout_width="match_parent"
        android:layout_height="180dp"
        android:background="@drawable/gradient_top" />

    <!-- Main content -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:paddingTop="48dp"
        android:paddingBottom="32dp">

        <!-- Top bar: Back + Title + Settings -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:paddingHorizontal="8dp"
            android:paddingBottom="8dp"
            android:gravity="center_vertical">

            <ImageButton
                android:id="@+id/btnClose"
                android:layout_width="44dp"
                android:layout_height="44dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:src="@drawable/ic_arrow_back"
                android:contentDescription="Kembali" />

            <TextView
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="Sedang Diputar"
                android:textSize="16sp"
                android:textStyle="bold"
                android:textColor="#FFFFFF"
                android:gravity="center" />

            <ImageButton
                android:id="@+id/btnSettings"
                android:layout_width="44dp"
                android:layout_height="44dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:src="@drawable/ic_settings"
                android:contentDescription="Pengaturan" />

        </LinearLayout>

        <!-- Album art besar (rounded square) -->
        <FrameLayout
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1"
            android:paddingHorizontal="32dp"
            android:paddingVertical="12dp">

            <ImageView
                android:id="@+id/imgAlbumArt"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:scaleType="centerCrop"
                android:background="@drawable/bg_album_rounded"
                android:clipToOutline="true"
                android:src="@drawable/ic_music_note"
                android:elevation="12dp" />

        </FrameLayout>

        <!-- Song info + like button -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:paddingHorizontal="28dp"
            android:paddingBottom="12dp"
            android:gravity="center_vertical">

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:id="@+id/tvTitle"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textSize="22sp"
                    android:textStyle="bold"
                    android:textColor="#FFFFFF"
                    android:maxLines="1"
                    android:ellipsize="end" />

                <TextView
                    android:id="@+id/tvArtist"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textSize="14sp"
                    android:textColor="#CCE8A87C"
                    android:maxLines="1"
                    android:ellipsize="end"
                    android:layout_marginTop="4dp" />

            </LinearLayout>

            <ImageButton
                android:id="@+id/btnLike"
                android:layout_width="44dp"
                android:layout_height="44dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:src="@drawable/ic_heart"
                android:contentDescription="Suka"
                android:layout_marginStart="8dp" />

        </LinearLayout>

        <!-- Seekbar + time -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingHorizontal="24dp"
            android:paddingBottom="12dp">

            <SeekBar
                android:id="@+id/seekBar"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:progressTint="#E8A87C"
                android:thumbTint="#E8A87C"
                android:progressBackgroundTint="#55FFFFFF" />

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:layout_marginTop="4dp">

                <TextView
                    android:id="@+id/tvCurrentTime"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="0:00"
                    android:textSize="12sp"
                    android:textColor="#CCFFFFFF" />

                <TextView
                    android:id="@+id/tvTotalTime"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="0:00"
                    android:textSize="12sp"
                    android:textColor="#CCFFFFFF" />

            </LinearLayout>

        </LinearLayout>

        <!-- Controls: prev, play/pause, next -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:paddingHorizontal="32dp"
            android:paddingBottom="16dp"
            android:gravity="center_vertical">

            <ImageButton
                android:id="@+id/btnPrev"
                android:layout_width="56dp"
                android:layout_height="56dp"
                android:background="@drawable/bg_btn_circle"
                android:src="@drawable/ic_skip_prev_white"
                android:padding="12dp"
                android:contentDescription="Sebelumnya" />

            <View android:layout_width="0dp" android:layout_height="1dp" android:layout_weight="1" />

            <!-- Play/Pause button (big white circle) -->
            <FrameLayout
                android:layout_width="72dp"
                android:layout_height="72dp">

                <View
                    android:layout_width="match_parent"
                    android:layout_height="match_parent"
                    android:background="@drawable/bg_play_big" />

                <ImageButton
                    android:id="@+id/btnPlayPause"
                    android:layout_width="match_parent"
                    android:layout_height="match_parent"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:src="@drawable/ic_play_dark"
                    android:contentDescription="Play/Pause"
                    android:padding="14dp" />

            </FrameLayout>

            <View android:layout_width="0dp" android:layout_height="1dp" android:layout_weight="1" />

            <ImageButton
                android:id="@+id/btnNext"
                android:layout_width="56dp"
                android:layout_height="56dp"
                android:background="@drawable/bg_btn_circle"
                android:src="@drawable/ic_skip_next_white"
                android:padding="12dp"
                android:contentDescription="Berikutnya" />

        </LinearLayout>

        <!-- Shortcut Pills: Shuffle, Repeat, Queue, Lyrics, Timer -->
        <HorizontalScrollView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:paddingHorizontal="20dp"
            android:scrollbars="none"
            android:fadingEdge="horizontal">

            <LinearLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center_vertical"
                android:padding="4dp">

                <!-- Shuffle -->
                <LinearLayout
                    android:id="@+id/pillShuffle"
                    android:layout_width="wrap_content"
                    android:layout_height="36dp"
                    android:background="@drawable/bg_pill"
                    android:orientation="horizontal"
                    android:gravity="center_vertical"
                    android:paddingHorizontal="14dp"
                    android:layout_marginEnd="8dp">
                    <ImageView
                        android:layout_width="16dp"
                        android:layout_height="16dp"
                        android:src="@drawable/ic_shuffle"
                        android:layout_marginEnd="6dp" />
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Acak"
                        android:textSize="13sp"
                        android:textStyle="bold"
                        android:textColor="#FFFFFF" />
                </LinearLayout>

                <!-- Repeat -->
                <LinearLayout
                    android:id="@+id/pillRepeat"
                    android:layout_width="wrap_content"
                    android:layout_height="36dp"
                    android:background="@drawable/bg_pill"
                    android:orientation="horizontal"
                    android:gravity="center_vertical"
                    android:paddingHorizontal="14dp"
                    android:layout_marginEnd="8dp">
                    <ImageView
                        android:layout_width="16dp"
                        android:layout_height="16dp"
                        android:src="@drawable/ic_repeat"
                        android:layout_marginEnd="6dp" />
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Ulangi"
                        android:textSize="13sp"
                        android:textStyle="bold"
                        android:textColor="#FFFFFF" />
                </LinearLayout>

                <!-- Queue -->
                <LinearLayout
                    android:id="@+id/pillQueue"
                    android:layout_width="wrap_content"
                    android:layout_height="36dp"
                    android:background="@drawable/bg_pill"
                    android:orientation="horizontal"
                    android:gravity="center_vertical"
                    android:paddingHorizontal="14dp"
                    android:layout_marginEnd="8dp">
                    <ImageView
                        android:layout_width="16dp"
                        android:layout_height="16dp"
                        android:src="@drawable/ic_queue"
                        android:layout_marginEnd="6dp" />
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Antrian"
                        android:textSize="13sp"
                        android:textStyle="bold"
                        android:textColor="#FFFFFF" />
                </LinearLayout>

                <!-- Lyrics -->
                <LinearLayout
                    android:id="@+id/pillLyrics"
                    android:layout_width="wrap_content"
                    android:layout_height="36dp"
                    android:background="@drawable/bg_pill"
                    android:orientation="horizontal"
                    android:gravity="center_vertical"
                    android:paddingHorizontal="14dp"
                    android:layout_marginEnd="8dp">
                    <ImageView
                        android:layout_width="16dp"
                        android:layout_height="16dp"
                        android:src="@drawable/ic_lyrics"
                        android:layout_marginEnd="6dp" />
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Lirik"
                        android:textSize="13sp"
                        android:textStyle="bold"
                        android:textColor="#FFFFFF" />
                </LinearLayout>

                <!-- Timer -->
                <LinearLayout
                    android:id="@+id/pillTimer"
                    android:layout_width="wrap_content"
                    android:layout_height="36dp"
                    android:background="@drawable/bg_pill"
                    android:orientation="horizontal"
                    android:gravity="center_vertical"
                    android:paddingHorizontal="14dp">
                    <ImageView
                        android:layout_width="16dp"
                        android:layout_height="16dp"
                        android:src="@drawable/ic_timer"
                        android:layout_marginEnd="6dp" />
                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Timer"
                        android:textSize="13sp"
                        android:textStyle="bold"
                        android:textColor="#FFFFFF" />
                </LinearLayout>

            </LinearLayout>
        </HorizontalScrollView>

    </LinearLayout>
</FrameLayout>
EOF

# ── NowPlayingActivity.kt ─────────────────────────────────────────────────────
cat > app/src/main/java/com/dioxd/floramusic/ui/NowPlayingActivity.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.SeekBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.palette.graphics.Palette
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ActivityNowPlayingBinding
import jp.wasabeef.blurry.Blurry

class NowPlayingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityNowPlayingBinding
    private val handler = Handler(Looper.getMainLooper())
    private var isSeeking = false
    private var isLiked = false

    private val updateProgress = object : Runnable {
        override fun run() {
            PlayerState.mediaPlayer?.let { mp ->
                if (!isSeeking) {
                    val pos = mp.currentPosition
                    val dur = mp.duration
                    if (dur > 0) {
                        binding.seekBar.max = dur
                        binding.seekBar.progress = pos
                        binding.tvCurrentTime.text = formatTime(pos)
                        binding.tvTotalTime.text   = formatTime(dur)
                    }
                }
            }
            handler.postDelayed(this, 500)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityNowPlayingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Transparent status bar
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        window.statusBarColor = android.graphics.Color.TRANSPARENT

        updateUI(PlayerState.currentSong)
        setupControls()
        setupPills()
        handler.post(updateProgress)
    }

    private fun setupControls() {
        binding.btnClose.setOnClickListener { finish() }

        binding.btnSettings.setOnClickListener {
            Toast.makeText(this, "⚙️ Pengaturan (coming soon)", Toast.LENGTH_SHORT).show()
        }

        binding.btnLike.setOnClickListener {
            isLiked = !isLiked
            binding.btnLike.setColorFilter(
                if (isLiked) android.graphics.Color.parseColor("#E8A87C")
                else android.graphics.Color.WHITE
            )
        }

        binding.btnPlayPause.setOnClickListener {
            PlayerState.mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause()
                    PlayerState.isPlaying = false
                    binding.btnPlayPause.setImageResource(R.drawable.ic_play_dark)
                } else {
                    it.start()
                    PlayerState.isPlaying = true
                    binding.btnPlayPause.setImageResource(R.drawable.ic_pause_dark)
                }
                PlayerState.onPlayStateChanged?.invoke(PlayerState.isPlaying)
            }
        }

        binding.btnNext.setOnClickListener {
            playAt((PlayerState.currentIndex + 1) % PlayerState.songs.size)
        }

        binding.btnPrev.setOnClickListener {
            val prev = if (PlayerState.currentIndex <= 0)
                PlayerState.songs.size - 1
            else
                PlayerState.currentIndex - 1
            playAt(prev)
        }

        binding.seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onStartTrackingTouch(sb: SeekBar) { isSeeking = true }
            override fun onStopTrackingTouch(sb: SeekBar) {
                PlayerState.mediaPlayer?.seekTo(sb.progress)
                isSeeking = false
            }
            override fun onProgressChanged(sb: SeekBar, progress: Int, fromUser: Boolean) {
                if (fromUser) binding.tvCurrentTime.text = formatTime(progress)
            }
        })
    }

    private fun setupPills() {
        binding.pillShuffle.setOnClickListener {
            PlayerState.shuffle = !PlayerState.shuffle
            binding.pillShuffle.background = getDrawable(
                if (PlayerState.shuffle) R.drawable.bg_pill_active else R.drawable.bg_pill
            )
        }

        binding.pillRepeat.setOnClickListener {
            PlayerState.repeat = !PlayerState.repeat
            binding.pillRepeat.background = getDrawable(
                if (PlayerState.repeat) R.drawable.bg_pill_active else R.drawable.bg_pill
            )
        }

        binding.pillQueue.setOnClickListener {
            Toast.makeText(this, "🎵 Antrian (coming soon)", Toast.LENGTH_SHORT).show()
        }

        binding.pillLyrics.setOnClickListener {
            Toast.makeText(this, "📝 Lirik (coming soon)", Toast.LENGTH_SHORT).show()
        }

        binding.pillTimer.setOnClickListener {
            Toast.makeText(this, "⏱️ Timer (coming soon)", Toast.LENGTH_SHORT).show()
        }
    }

    private fun updateUI(song: Song?) {
        song ?: return
        binding.tvTitle.text  = song.title
        binding.tvArtist.text = song.artist

        updatePlayButton()

        // Load album art + blur background
        Glide.with(this)
            .asBitmap()
            .load(song.albumArtUri)
            .into(object : CustomTarget<Bitmap>() {
                override fun onResourceReady(bitmap: Bitmap, transition: Transition<in Bitmap>?) {
                    // Album art
                    binding.imgAlbumArt.setImageBitmap(bitmap)

                    // Blur background
                    Blurry.with(applicationContext)
                        .radius(20)
                        .sampling(4)
                        .from(bitmap)
                        .into(binding.imgBgBlur)
                }

                override fun onLoadCleared(placeholder: Drawable?) {
                    // Fallback: solid dark background (no cover)
                    binding.imgBgBlur.setImageDrawable(null)
                    binding.imgBgBlur.setBackgroundColor(
                        android.graphics.Color.parseColor("#2d2420")
                    )
                }

                override fun onLoadFailed(errorDrawable: Drawable?) {
                    // No cover art — gunakan background solid + aksen subtle
                    binding.imgBgBlur.setImageDrawable(null)
                    binding.imgBgBlur.setBackgroundColor(
                        android.graphics.Color.parseColor("#2d2420")
                    )
                    binding.imgAlbumArt.setImageResource(R.drawable.ic_music_note)
                }
            })
    }

    private fun playAt(index: Int) {
        if (PlayerState.songs.isEmpty()) return
        val song = PlayerState.songs[index]
        PlayerState.currentIndex = index
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = MediaPlayer().apply {
            setDataSource(applicationContext, song.uri)
            prepare()
            start()
            setOnCompletionListener {
                if (PlayerState.repeat) { seekTo(0); start() }
                else playAt((PlayerState.currentIndex + 1) % PlayerState.songs.size)
            }
        }
        PlayerState.isPlaying = true
        updateUI(song)
        PlayerState.onSongChanged?.invoke(song)
    }

    private fun updatePlayButton() {
        val isPlaying = PlayerState.mediaPlayer?.isPlaying == true
        binding.btnPlayPause.setImageResource(
            if (isPlaying) R.drawable.ic_pause_dark else R.drawable.ic_play_dark
        )
    }

    private fun formatTime(ms: Int): String {
        val m = ms / 1000 / 60
        val s = (ms / 1000) % 60
        return "%d:%02d".format(m, s)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(updateProgress)
    }
}
EOF

# ── settings.gradle.kts - tambah JitPack untuk Blurry ────────────────────────
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
        maven { url = uri("https://jitpack.io") }
    }
}
rootProject.name = "FloraMusic"
include(":app")
EOF

echo ""
echo "✅ NowPlaying screen berhasil diupdate!"
echo ""
echo "Sekarang jalankan:"
echo "  git add ."
echo "  git commit -m 'feat: now playing with blur bg + pills + settings'"
echo "  git pull --rebase && git push"
