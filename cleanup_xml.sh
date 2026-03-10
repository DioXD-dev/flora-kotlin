#!/bin/bash
# Hapus semua file XML resource lama yang menyebabkan konflik
# Jalankan di dalam folder ~/flora-kotlin

echo "🧹 Membersihkan file XML lama..."

RES="app/src/main/res"

# Hapus semua drawable XML lama (yang pakai ?attr/ dari View system)
rm -f "$RES/drawable/bg_album_art.xml"
rm -f "$RES/drawable/bg_album_rounded.xml"
rm -f "$RES/drawable/bg_card.xml"
rm -f "$RES/drawable/bg_handle.xml"
rm -f "$RES/drawable/bg_mini_player.xml"
rm -f "$RES/drawable/bg_pill.xml"
rm -f "$RES/drawable/bg_pill_active.xml"
rm -f "$RES/drawable/bg_pill_bar.xml"
rm -f "$RES/drawable/bg_pill_icon_active.xml"
rm -f "$RES/drawable/bg_pill_nav.xml"
rm -f "$RES/drawable/bg_play_accent.xml"
rm -f "$RES/drawable/bg_play_big.xml"
rm -f "$RES/drawable/bg_play_btn.xml"
rm -f "$RES/drawable/bg_playing_dot.xml"
rm -f "$RES/drawable/bg_tab_indicator.xml"
rm -f "$RES/drawable/gradient_bottom.xml"
rm -f "$RES/drawable/gradient_top.xml"
rm -f "$RES/drawable/ic_arrow_back.xml"
rm -f "$RES/drawable/ic_arrow_down.xml"
rm -f "$RES/drawable/ic_heart.xml"
rm -f "$RES/drawable/ic_heart_filled.xml"
rm -f "$RES/drawable/ic_lyrics.xml"
rm -f "$RES/drawable/ic_music_note.xml"
rm -f "$RES/drawable/ic_nav_favorite.xml"
rm -f "$RES/drawable/ic_nav_home.xml"
rm -f "$RES/drawable/ic_nav_playlist.xml"
rm -f "$RES/drawable/ic_nav_radio.xml"
rm -f "$RES/drawable/ic_nav_search.xml"
rm -f "$RES/drawable/ic_pause.xml"
rm -f "$RES/drawable/ic_pause_dark.xml"
rm -f "$RES/drawable/ic_play.xml"
rm -f "$RES/drawable/ic_play_dark.xml"
rm -f "$RES/drawable/ic_queue.xml"
rm -f "$RES/drawable/ic_repeat.xml"
rm -f "$RES/drawable/ic_search.xml"
rm -f "$RES/drawable/ic_settings.xml"
rm -f "$RES/drawable/ic_shuffle.xml"
rm -f "$RES/drawable/ic_skip_next.xml"
rm -f "$RES/drawable/ic_skip_next_accent.xml"
rm -f "$RES/drawable/ic_skip_next_white.xml"
rm -f "$RES/drawable/ic_skip_prev.xml"
rm -f "$RES/drawable/ic_skip_prev_accent.xml"
rm -f "$RES/drawable/ic_skip_prev_white.xml"
rm -f "$RES/drawable/ic_timer.xml"
rm -f "$RES/drawable/pill_separator.xml"

# Hapus layout XML lama (sudah tidak dipakai di Compose)
rm -rf "$RES/layout/"

# Hapus values-night lama (mungkin ada yang konflik)
rm -f "$RES/values-night/themes.xml"

# Tulis ulang values-night/themes.xml yang bersih
mkdir -p "$RES/values-night"
cat > "$RES/values-night/themes.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.FloraMusic" parent="Theme.Material3.DayNight.NoActionBar" />
</resources>
EOF

echo "  ✓ File XML lama dihapus"
echo "  ✓ values-night/themes.xml dibuat ulang"

echo ""
echo "Sekarang:"
echo "  git add ."
echo "  git commit -m 'fix: hapus XML lama, bersihkan resource konflik'"
echo "  git pull --rebase && git push"
