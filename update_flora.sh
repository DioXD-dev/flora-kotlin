#!/bin/bash
# Flora Music Kotlin - Update to match React design
# Jalankan di dalam folder ~/flora-kotlin

echo "🌿 Mengupdate Flora Music ke desain React..."

mkdir -p app/src/main/java/com/dioxd/floramusic/ui
mkdir -p app/src/main/res/{layout,values,values-night,drawable,anim}

# ── COLORS (warm cream + green + orange like React version) ──────────────────
cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Light mode - warm cream palette -->
    <color name="bg">#FFFDF9</color>
    <color name="surface">#F5F0EB</color>
    <color name="surface2">#EDE8E2</color>
    <color name="primary">#4a9460</color>
    <color name="primary_dark">#2d5a3d</color>
    <color name="accent">#E8A87C</color>
    <color name="accent_dark">#7a4520</color>
    <color name="text_primary">#1a1a1a</color>
    <color name="text_secondary">#888888</color>
    <color name="divider">#E8E3DC</color>

    <!-- Dark mode -->
    <color name="bg_dark">#1A1714</color>
    <color name="surface_dark">#242019</color>
    <color name="surface2_dark">#2E2922</color>
    <color name="text_primary_dark">#F0EBE3</color>
    <color name="text_secondary_dark">#9A9490</color>
    <color name="divider_dark">#333028</color>
</resources>
EOF

# ── THEMES ────────────────────────────────────────────────────────────────────
cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.FloraMusic" parent="Theme.Material3.Light.NoActionBar">
        <item name="colorPrimary">#4a9460</item>
        <item name="colorOnPrimary">#FFFFFF</item>
        <item name="colorPrimaryContainer">#C8EDCC</item>
        <item name="colorSecondary">#E8A87C</item>
        <item name="colorSecondaryContainer">#FDEBD8</item>
        <item name="colorOnSecondaryContainer">#4a2010</item>
        <item name="colorSurface">#FFFDF9</item>
        <item name="colorSurfaceVariant">#F5F0EB</item>
        <item name="colorOnSurface">#1a1a1a</item>
        <item name="colorOnSurfaceVariant">#666660</item>
        <item name="android:colorBackground">#FFFDF9</item>
        <item name="android:statusBarColor">#FFFDF9</item>
        <item name="android:navigationBarColor">#FFFDF9</item>
        <item name="android:windowLightStatusBar">true</item>
        <item name="android:windowLightNavigationBar">true</item>
    </style>
    <style name="Theme.FloraMusic.NowPlaying" parent="Theme.FloraMusic">
        <item name="android:windowBackground">@color/bg</item>
    </style>
</resources>
EOF

cat > app/src/main/res/values-night/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.FloraMusic" parent="Theme.Material3.Dark.NoActionBar">
        <item name="colorPrimary">#7EC8A0</item>
        <item name="colorOnPrimary">#1a3d28</item>
        <item name="colorPrimaryContainer">#2d5a3d</item>
        <item name="colorSecondary">#E8A87C</item>
        <item name="colorSecondaryContainer">#4a2010</item>
        <item name="colorOnSecondaryContainer">#FDEBD8</item>
        <item name="colorSurface">#1A1714</item>
        <item name="colorSurfaceVariant">#242019</item>
        <item name="colorOnSurface">#F0EBE3</item>
        <item name="colorOnSurfaceVariant">#9A9490</item>
        <item name="android:colorBackground">#1A1714</item>
        <item name="android:statusBarColor">#1A1714</item>
        <item name="android:navigationBarColor">#1A1714</item>
        <item name="android:windowLightStatusBar">false</item>
        <item name="android:windowLightNavigationBar">false</item>
    </style>
    <style name="Theme.FloraMusic.NowPlaying" parent="Theme.FloraMusic">
        <item name="android:windowBackground">@color/bg_dark</item>
    </style>
</resources>
EOF

# ── STRINGS ───────────────────────────────────────────────────────────────────
cat > app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Flora Music</string>
    <string name="no_song">Tidak ada lagu</string>
    <string name="unknown_artist">Artis tidak diketahui</string>
    <string name="search_hint">Cari lagu, artis, album…</string>
</resources>
EOF

# ── DRAWABLES ─────────────────────────────────────────────────────────────────
cat > app/src/main/res/drawable/bg_album_art.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="?attr/colorSurfaceVariant" />
</shape>
EOF

cat > app/src/main/res/drawable/bg_card.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="16dp" />
    <solid android:color="?attr/colorSurfaceVariant" />
</shape>
EOF

cat > app/src/main/res/drawable/bg_mini_player.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="20dp" />
    <solid android:color="?attr/colorSecondaryContainer" />
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
    android:width="32dp" android:height="32dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="?attr/colorOnSecondaryContainer"
        android:pathData="M8,5v14l11,-7z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_pause.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="32dp" android:height="32dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="?attr/colorOnSecondaryContainer"
        android:pathData="M6,19h4V5H6v14zm8,-14v14h4V5h-4z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_skip_next.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="28dp" android:height="28dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="?attr/colorOnSurface"
        android:pathData="M6,18l8.5,-6L6,6v12zM16,6v12h2V6h-2z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_skip_prev.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="28dp" android:height="28dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="?attr/colorOnSurface"
        android:pathData="M6,6h2v12H6zm3.5,6l8.5,6V6z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_search.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSurface">
    <path android:fillColor="@android:color/white"
        android:pathData="M15.5,14h-0.79l-0.28,-0.27C15.41,12.59 16,11.11 16,9.5 16,5.91 13.09,3 9.5,3S3,5.91 3,9.5 5.91,16 9.5,16c1.61,0 3.09,-0.59 4.23,-1.57l0.27,0.28v0.79l5,4.99L20.49,19l-4.99,-5zM9.5,14C7.01,14 5,11.99 5,9.5S7.01,5 9.5,5 14,7.01 14,9.5 11.99,14 9.5,14z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_arrow_down.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSurface">
    <path android:fillColor="@android:color/white"
        android:pathData="M7.41,8.59L12,13.17l4.59,-4.58L18,10l-6,6 -6,-6 1.41,-1.41z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_shuffle.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSurface">
    <path android:fillColor="@android:color/white"
        android:pathData="M10.59,9.17L5.41,4 4,5.41l5.17,5.17 1.42,-1.41zM14.5,4l2.04,2.04L4,18.59 5.41,20 17.96,7.46 20,9.5V4h-5.5zM14.83,13.41l-1.41,1.41 3.13,3.13L14.5,20H20v-5.5l-2.04,2.04 -3.13,-3.13z"/>
</vector>
EOF

cat > app/src/main/res/drawable/ic_repeat.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24"
    android:tint="?attr/colorOnSurface">
    <path android:fillColor="@android:color/white"
        android:pathData="M7,7h10v3l4,-4 -4,-4v3H5v6h2V7zM17,17H7v-3l-4,4 4,4v-3h12v-6h-2v4z"/>
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

# launcher icons
LAUNCHER_XML='<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/white" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>'
for d in hdpi mdpi xhdpi xxhdpi xxxhdpi; do
    mkdir -p app/src/main/res/mipmap-$d
    echo "$LAUNCHER_XML" > app/src/main/res/mipmap-$d/ic_launcher.xml
    echo "$LAUNCHER_XML" > app/src/main/res/mipmap-$d/ic_launcher_round.xml
done

# ── ANIMATIONS ────────────────────────────────────────────────────────────────
cat > app/src/main/res/anim/slide_up.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <translate android:fromYDelta="100%" android:toYDelta="0"
        android:duration="380" android:interpolator="@android:interpolator/decelerate_cubic"/>
</set>
EOF

cat > app/src/main/res/anim/slide_down.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
    <translate android:fromYDelta="0" android:toYDelta="100%"
        android:duration="250" android:interpolator="@android:interpolator/accelerate_cubic"/>
    <alpha android:fromAlpha="1" android:toAlpha="0.3" android:duration="250"/>
</set>
EOF

# ── LAYOUTS ───────────────────────────────────────────────────────────────────

# activity_main.xml
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?attr/colorSurface">

    <!-- AppBar -->
    <com.google.android.material.appbar.AppBarLayout
        android:id="@+id/appBarLayout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="?attr/colorSurface"
        app:elevation="0dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:paddingStart="20dp"
            android:paddingEnd="12dp"
            android:paddingTop="16dp"
            android:paddingBottom="8dp"
            android:gravity="center_vertical">

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:text="🌿 Flora Music"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textSize="22sp"
                    android:textStyle="bold"
                    android:textColor="?attr/colorOnSurface" />

                <TextView
                    android:id="@+id/tvSongCount"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Memuat lagu..."
                    android:textSize="12sp"
                    android:textColor="?attr/colorOnSurfaceVariant" />

            </LinearLayout>

            <!-- Search button -->
            <ImageButton
                android:id="@+id/btnSearch"
                android:layout_width="44dp"
                android:layout_height="44dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:src="@drawable/ic_search"
                android:contentDescription="Cari" />

        </LinearLayout>

    </com.google.android.material.appbar.AppBarLayout>

    <!-- Song list -->
    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/recyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:clipToPadding="false"
        android:paddingTop="8dp"
        android:paddingBottom="110dp"
        app:layout_behavior="@string/appbar_scrolling_view_behavior"
        app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

    <!-- Mini Player -->
    <FrameLayout
        android:id="@+id/miniPlayerContainer"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:visibility="gone">

        <LinearLayout
            android:id="@+id/miniPlayer"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_margin="12dp"
            android:background="@drawable/bg_mini_player"
            android:orientation="horizontal"
            android:padding="12dp"
            android:gravity="center_vertical"
            android:elevation="8dp">

            <ImageView
                android:id="@+id/imgNowArt"
                android:layout_width="46dp"
                android:layout_height="46dp"
                android:scaleType="centerCrop"
                android:background="@drawable/bg_album_art"
                android:clipToOutline="true"
                android:src="@drawable/ic_music_note" />

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical"
                android:layout_marginStart="12dp"
                android:layout_marginEnd="4dp">

                <TextView
                    android:id="@+id/tvNowTitle"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:text="Tidak ada lagu"
                    android:textSize="14sp"
                    android:textStyle="bold"
                    android:textColor="?attr/colorOnSecondaryContainer"
                    android:maxLines="1"
                    android:ellipsize="end" />

                <TextView
                    android:id="@+id/tvNowArtist"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:text="—"
                    android:textSize="12sp"
                    android:textColor="?attr/colorOnSecondaryContainer"
                    android:maxLines="1"
                    android:ellipsize="end" />

            </LinearLayout>

            <ImageButton
                android:id="@+id/btnPrev"
                android:layout_width="38dp"
                android:layout_height="38dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:src="@drawable/ic_skip_prev"
                android:contentDescription="Sebelumnya" />

            <ImageButton
                android:id="@+id/btnPlayPause"
                android:layout_width="44dp"
                android:layout_height="44dp"
                android:background="@drawable/bg_play_btn"
                android:src="@drawable/ic_play"
                android:contentDescription="Play/Pause"
                android:layout_marginStart="2dp"
                android:layout_marginEnd="2dp" />

            <ImageButton
                android:id="@+id/btnNext"
                android:layout_width="38dp"
                android:layout_height="38dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:src="@drawable/ic_skip_next"
                android:contentDescription="Berikutnya" />

        </LinearLayout>

    </FrameLayout>

    <!-- Search overlay -->
    <FrameLayout
        android:id="@+id/searchOverlay"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="?attr/colorSurface"
        android:visibility="gone">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:orientation="vertical">

            <!-- Search bar -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:padding="12dp"
                android:gravity="center_vertical">

                <com.google.android.material.textfield.TextInputLayout
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    style="@style/Widget.Material3.TextInputLayout.OutlinedBox"
                    android:hint="@string/search_hint">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/etSearch"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:imeOptions="actionSearch"
                        android:inputType="text"
                        android:maxLines="1" />

                </com.google.android.material.textfield.TextInputLayout>

                <Button
                    android:id="@+id/btnCloseSearch"
                    style="@style/Widget.Material3.Button.TextButton"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Batal"
                    android:layout_marginStart="4dp" />

            </LinearLayout>

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/searchRecycler"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:clipToPadding="false"
                android:paddingBottom="16dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

        </LinearLayout>

    </FrameLayout>

</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

# bg_play_btn drawable
cat > app/src/main/res/drawable/bg_play_btn.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="?attr/colorSecondary" />
</shape>
EOF

# item_song.xml
cat > app/src/main/res/layout/item_song.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:paddingHorizontal="16dp"
    android:paddingVertical="8dp"
    android:gravity="center_vertical"
    android:background="?attr/selectableItemBackground">

    <!-- Album art (rounded square) -->
    <ImageView
        android:id="@+id/imgAlbumArt"
        android:layout_width="52dp"
        android:layout_height="52dp"
        android:scaleType="centerCrop"
        android:background="@drawable/bg_card"
        android:clipToOutline="true"
        android:src="@drawable/ic_music_note" />

    <!-- Info -->
    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:orientation="vertical"
        android:layout_marginStart="14dp">

        <TextView
            android:id="@+id/tvTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="15sp"
            android:textStyle="bold"
            android:textColor="?attr/colorOnSurface"
            android:maxLines="1"
            android:ellipsize="end" />

        <TextView
            android:id="@+id/tvArtist"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="12sp"
            android:textColor="?attr/colorOnSurfaceVariant"
            android:maxLines="1"
            android:ellipsize="end"
            android:layout_marginTop="2dp" />

    </LinearLayout>

    <!-- Duration -->
    <TextView
        android:id="@+id/tvDuration"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textSize="11sp"
        android:textColor="?attr/colorOnSurfaceVariant"
        android:layout_marginStart="8dp" />

    <!-- Playing indicator -->
    <View
        android:id="@+id/playingIndicator"
        android:layout_width="6dp"
        android:layout_height="6dp"
        android:layout_marginStart="6dp"
        android:background="@drawable/bg_playing_dot"
        android:visibility="gone" />

</LinearLayout>
EOF

# playing indicator dot
cat > app/src/main/res/drawable/bg_playing_dot.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#4a9460" />
</shape>
EOF

# activity_now_playing.xml - Full screen Now Playing
cat > app/src/main/res/layout/activity_now_playing.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="?attr/colorSurface"
    android:paddingBottom="32dp">

    <!-- Handle bar -->
    <View
        android:layout_width="40dp"
        android:layout_height="4dp"
        android:layout_gravity="center_horizontal"
        android:layout_marginTop="12dp"
        android:background="@drawable/bg_handle"
        android:layout_marginBottom="8dp" />

    <!-- Top bar: close + title -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:paddingHorizontal="8dp"
        android:paddingVertical="4dp"
        android:gravity="center_vertical">

        <ImageButton
            android:id="@+id/btnClose"
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@drawable/ic_arrow_down"
            android:contentDescription="Tutup" />

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Sedang Diputar"
            android:textSize="14sp"
            android:textStyle="bold"
            android:textColor="?attr/colorOnSurface"
            android:gravity="center" />

        <!-- Spacer -->
        <View android:layout_width="44dp" android:layout_height="44dp" />

    </LinearLayout>

    <!-- Album art (large, circular, spinning) -->
    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:gravity="center"
        android:paddingHorizontal="48dp"
        android:paddingVertical="16dp">

        <ImageView
            android:id="@+id/imgAlbumArt"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:scaleType="centerCrop"
            android:background="@drawable/bg_album_art"
            android:clipToOutline="true"
            android:src="@drawable/ic_music_note"
            android:elevation="8dp" />

    </FrameLayout>

    <!-- Song info -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:paddingHorizontal="32dp"
        android:paddingBottom="8dp">

        <TextView
            android:id="@+id/tvTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="20sp"
            android:textStyle="bold"
            android:textColor="?attr/colorOnSurface"
            android:maxLines="1"
            android:ellipsize="end" />

        <TextView
            android:id="@+id/tvArtist"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="14sp"
            android:textColor="#4a9460"
            android:maxLines="1"
            android:ellipsize="end"
            android:layout_marginTop="4dp" />

    </LinearLayout>

    <!-- Progress bar + time -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:paddingHorizontal="28dp"
        android:paddingBottom="8dp">

        <SeekBar
            android:id="@+id/seekBar"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:progressTint="#4a9460"
            android:thumbTint="#4a9460" />

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal">

            <TextView
                android:id="@+id/tvCurrentTime"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="0:00"
                android:textSize="11sp"
                android:textColor="?attr/colorOnSurfaceVariant" />

            <TextView
                android:id="@+id/tvTotalTime"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="0:00"
                android:textSize="11sp"
                android:textColor="?attr/colorOnSurfaceVariant" />

        </LinearLayout>

    </LinearLayout>

    <!-- Controls: shuffle, prev, play/pause, next, repeat -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:paddingHorizontal="24dp"
        android:paddingBottom="8dp"
        android:gravity="center_vertical">

        <ImageButton
            android:id="@+id/btnShuffle"
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@drawable/ic_shuffle"
            android:alpha="0.4"
            android:contentDescription="Acak" />

        <View android:layout_width="0dp" android:layout_height="1dp" android:layout_weight="1" />

        <ImageButton
            android:id="@+id/btnPrev"
            android:layout_width="52dp"
            android:layout_height="52dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@drawable/ic_skip_prev"
            android:contentDescription="Sebelumnya" />

        <!-- Play/Pause big button -->
        <FrameLayout
            android:layout_width="68dp"
            android:layout_height="68dp"
            android:layout_marginHorizontal="12dp">

            <View
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:background="@drawable/bg_play_big" />

            <ImageButton
                android:id="@+id/btnPlayPause"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:src="@drawable/ic_play"
                android:contentDescription="Play/Pause"
                android:padding="14dp" />

        </FrameLayout>

        <ImageButton
            android:id="@+id/btnNext"
            android:layout_width="52dp"
            android:layout_height="52dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@drawable/ic_skip_next"
            android:contentDescription="Berikutnya" />

        <View android:layout_width="0dp" android:layout_height="1dp" android:layout_weight="1" />

        <ImageButton
            android:id="@+id/btnRepeat"
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:src="@drawable/ic_repeat"
            android:alpha="0.4"
            android:contentDescription="Ulangi" />

    </LinearLayout>

</LinearLayout>
EOF

# big play button bg
cat > app/src/main/res/drawable/bg_play_big.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#4a9460" />
</shape>
EOF

# handle bar drawable
cat > app/src/main/res/drawable/bg_handle.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="4dp" />
    <solid android:color="?attr/colorOnSurfaceVariant" />
    <size android:width="40dp" android:height="4dp" />
</shape>
EOF

# ── KOTLIN FILES ──────────────────────────────────────────────────────────────

# Song.kt
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

# MusicRepository.kt
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

# PlayerState.kt - shared state
cat > app/src/main/java/com/dioxd/floramusic/data/PlayerState.kt << 'EOF'
package com.dioxd.floramusic.data

import android.media.MediaPlayer
import com.dioxd.floramusic.data.Song

object PlayerState {
    var mediaPlayer: MediaPlayer? = null
    var songs: List<Song> = emptyList()
    var currentIndex: Int = -1
    var isPlaying: Boolean = false
    var shuffle: Boolean = false
    var repeat: Boolean = false

    val currentSong: Song? get() = songs.getOrNull(currentIndex)

    var onSongChanged: ((Song) -> Unit)? = null
    var onPlayStateChanged: ((Boolean) -> Unit)? = null
}
EOF

# SongAdapter.kt
cat > app/src/main/java/com/dioxd/floramusic/ui/SongAdapter.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.view.LayoutInflater
import android.view.View
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
            val isPlaying = song.id == nowPlayingId
            binding.tvTitle.text    = song.title
            binding.tvArtist.text   = song.artist
            binding.tvDuration.text = song.durationText
            binding.playingIndicator.visibility = if (isPlaying) View.VISIBLE else View.GONE
            binding.tvTitle.alpha = if (isPlaying) 1f else 0.9f

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

# NowPlayingActivity.kt
cat > app/src/main/java/com/dioxd/floramusic/ui/NowPlayingActivity.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.animation.AnimationUtils
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import com.bumptech.glide.Glide
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ActivityNowPlayingBinding

class NowPlayingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityNowPlayingBinding
    private val handler = Handler(Looper.getMainLooper())
    private var isSeeking = false

    private val updateProgress = object : Runnable {
        override fun run() {
            PlayerState.mediaPlayer?.let { mp ->
                if (!isSeeking && mp.isPlaying) {
                    val pos = mp.currentPosition
                    val dur = mp.duration
                    binding.seekBar.max = dur
                    binding.seekBar.progress = pos
                    binding.tvCurrentTime.text = formatTime(pos)
                    binding.tvTotalTime.text   = formatTime(dur)
                }
            }
            handler.postDelayed(this, 500)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityNowPlayingBinding.inflate(layoutInflater)
        setContentView(binding.root)

        updateUI(PlayerState.currentSong)

        binding.btnClose.setOnClickListener { finish() }

        binding.btnPlayPause.setOnClickListener {
            PlayerState.mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause()
                    PlayerState.isPlaying = false
                } else {
                    it.start()
                    PlayerState.isPlaying = true
                }
                updatePlayButton()
                PlayerState.onPlayStateChanged?.invoke(PlayerState.isPlaying)
            }
        }

        binding.btnNext.setOnClickListener {
            playNext()
            PlayerState.onSongChanged?.invoke(PlayerState.currentSong!!)
        }

        binding.btnPrev.setOnClickListener {
            playPrev()
            PlayerState.onSongChanged?.invoke(PlayerState.currentSong!!)
        }

        binding.btnShuffle.setOnClickListener {
            PlayerState.shuffle = !PlayerState.shuffle
            binding.btnShuffle.alpha = if (PlayerState.shuffle) 1f else 0.4f
        }

        binding.btnRepeat.setOnClickListener {
            PlayerState.repeat = !PlayerState.repeat
            binding.btnRepeat.alpha = if (PlayerState.repeat) 1f else 0.4f
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

        handler.post(updateProgress)
    }

    private fun updateUI(song: Song?) {
        song ?: return
        binding.tvTitle.text  = song.title
        binding.tvArtist.text = song.artist
        binding.tvTotalTime.text = song.durationText

        Glide.with(this)
            .load(song.albumArtUri)
            .placeholder(R.drawable.ic_music_note)
            .error(R.drawable.ic_music_note)
            .centerCrop()
            .into(binding.imgAlbumArt)

        updatePlayButton()
    }

    private fun updatePlayButton() {
        val isPlaying = PlayerState.mediaPlayer?.isPlaying == true
        binding.btnPlayPause.setImageResource(
            if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
        )
    }

    private fun playNext() {
        val songs = PlayerState.songs
        if (songs.isEmpty()) return
        val next = if (PlayerState.shuffle)
            (0 until songs.size).random()
        else
            (PlayerState.currentIndex + 1) % songs.size
        playSong(next)
    }

    private fun playPrev() {
        val songs = PlayerState.songs
        if (songs.isEmpty()) return
        val prev = if (PlayerState.currentIndex <= 0) songs.size - 1 else PlayerState.currentIndex - 1
        playSong(prev)
    }

    private fun playSong(index: Int) {
        val song = PlayerState.songs[index]
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
        updateUI(song)
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

# MainActivity.kt
cat > app/src/main/java/com/dioxd/floramusic/ui/MainActivity.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.MusicRepository
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: SongAdapter
    private lateinit var searchAdapter: SongAdapter

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

        setupAdapters()
        setupMiniPlayer()
        setupSearch()
        checkPermission()

        // Update UI saat kembali dari NowPlaying
        PlayerState.onSongChanged = { song ->
            runOnUiThread {
                adapter.nowPlayingId = song.id
                searchAdapter.nowPlayingId = song.id
                updateMiniPlayer(song)
            }
        }
        PlayerState.onPlayStateChanged = { isPlaying ->
            runOnUiThread {
                binding.btnPlayPause.setImageResource(
                    if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
                )
            }
        }
    }

    private fun setupAdapters() {
        adapter = SongAdapter { song, index -> playSong(song, index) }
        binding.recyclerView.adapter = adapter

        searchAdapter = SongAdapter { song, index ->
            val realIndex = PlayerState.songs.indexOfFirst { it.id == song.id }
            playSong(song, realIndex)
            closeSearch()
        }
        binding.searchRecycler.adapter = searchAdapter
    }

    private fun setupMiniPlayer() {
        binding.miniPlayer.setOnClickListener {
            startActivity(Intent(this, NowPlayingActivity::class.java))
            overridePendingTransition(R.anim.slide_up, 0)
        }

        binding.btnPlayPause.setOnClickListener {
            PlayerState.mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause(); PlayerState.isPlaying = false
                } else {
                    it.start(); PlayerState.isPlaying = true
                }
                binding.btnPlayPause.setImageResource(
                    if (PlayerState.isPlaying) R.drawable.ic_pause else R.drawable.ic_play
                )
            }
        }

        binding.btnNext.setOnClickListener {
            val songs = PlayerState.songs
            if (songs.isEmpty()) return@setOnClickListener
            val next = (PlayerState.currentIndex + 1) % songs.size
            playSong(songs[next], next)
        }

        binding.btnPrev.setOnClickListener {
            val songs = PlayerState.songs
            if (songs.isEmpty()) return@setOnClickListener
            val prev = if (PlayerState.currentIndex <= 0) songs.size - 1 else PlayerState.currentIndex - 1
            playSong(songs[prev], prev)
        }
    }

    private fun setupSearch() {
        binding.btnSearch.setOnClickListener {
            binding.searchOverlay.visibility = View.VISIBLE
            binding.etSearch.requestFocus()
        }

        binding.btnCloseSearch.setOnClickListener { closeSearch() }

        binding.etSearch.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val query = s?.toString()?.lowercase() ?: ""
                val filtered = PlayerState.songs.filter {
                    it.title.lowercase().contains(query) ||
                    it.artist.lowercase().contains(query) ||
                    it.album.lowercase().contains(query)
                }
                searchAdapter.submitList(filtered)
            }
            override fun afterTextChanged(s: Editable?) {}
        })
    }

    private fun closeSearch() {
        binding.searchOverlay.visibility = View.GONE
        binding.etSearch.setText("")
    }

    private fun checkPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.READ_MEDIA_AUDIO else Manifest.permission.READ_EXTERNAL_STORAGE
        if (ContextCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED)
            loadSongs() else permLauncher.launch(perm)
    }

    private fun loadSongs() {
        val songs = MusicRepository.getAllSongs(this)
        PlayerState.songs = songs
        adapter.submitList(songs)
        searchAdapter.submitList(songs)
        binding.tvSongCount.text = "${songs.size} lagu"
    }

    private fun playSong(song: Song, index: Int) {
        PlayerState.currentIndex = index
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = MediaPlayer().apply {
            setDataSource(applicationContext, song.uri)
            prepare()
            start()
            setOnCompletionListener {
                val next = (PlayerState.currentIndex + 1) % PlayerState.songs.size
                playSong(PlayerState.songs[next], next)
            }
        }
        PlayerState.isPlaying = true
        adapter.nowPlayingId = song.id
        searchAdapter.nowPlayingId = song.id
        updateMiniPlayer(song)
    }

    private fun updateMiniPlayer(song: Song) {
        binding.miniPlayerContainer.visibility = View.VISIBLE
        binding.tvNowTitle.text  = song.title
        binding.tvNowArtist.text = song.artist
        binding.btnPlayPause.setImageResource(R.drawable.ic_pause)
        Glide.with(this)
            .load(song.albumArtUri)
            .placeholder(R.drawable.ic_music_note)
            .error(R.drawable.ic_music_note)
            .centerCrop()
            .into(binding.imgNowArt)
    }

    override fun onResume() {
        super.onResume()
        // Sync state saat balik dari NowPlaying
        PlayerState.currentSong?.let {
            adapter.nowPlayingId = it.id
            binding.btnPlayPause.setImageResource(
                if (PlayerState.isPlaying) R.drawable.ic_pause else R.drawable.ic_play
            )
        }
    }
}
EOF

# ── AndroidManifest (tambah NowPlayingActivity) ───────────────────────────────
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

        <activity
            android:name=".ui.NowPlayingActivity"
            android:exported="false"
            android:theme="@style/Theme.FloraMusic.NowPlaying" />

    </application>
</manifest>
EOF

echo ""
echo "✅ Update selesai!"
echo ""
echo "Sekarang jalankan:"
echo "  git add ."
echo "  git commit -m 'redesign: Flora Music mirip versi React'"
echo "  git pull --rebase && git push"
