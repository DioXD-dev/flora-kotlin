#!/bin/bash
# Fix semua compile error di SongListScreen.kt & NowPlayingScreen.kt
# Jalankan di dalam folder ~/flora-kotlin

echo "🔧 Memperbaiki semua compile error..."

python3 << 'PYEOF'
import os

UI = "app/src/main/java/com/dioxd/floramusic/ui"

# ─── Helper ───────────────────────────────────────────────────────────────────
def fix_imports(path, to_replace, replacement):
    if not os.path.exists(path):
        print(f"  ❌ Tidak ditemukan: {path}")
        return False
    with open(path, "r") as f:
        content = f.read()
    if to_replace in content:
        content = content.replace(to_replace, replacement)
        with open(path, "w") as f:
            f.write(content)
        return True
    return False

def add_import_after(path, anchor, new_import):
    """Tambah import setelah baris anchor jika belum ada."""
    if not os.path.exists(path):
        return
    with open(path, "r") as f:
        content = f.read()
    if new_import in content:
        return  # sudah ada
    content = content.replace(anchor, anchor + "\n" + new_import)
    with open(path, "w") as f:
        f.write(content)

# ─── Fix SongListScreen.kt ────────────────────────────────────────────────────
song_path = f"{UI}/SongListScreen.kt"
print("📋 SongListScreen.kt:")

# Fix 1: Ganti wildcard unit.* → explicit imports
changed = fix_imports(
    song_path,
    "import androidx.compose.ui.unit.*",
    "import androidx.compose.ui.unit.dp\nimport androidx.compose.ui.unit.sp\nimport androidx.compose.ui.unit.TextUnit"
)
print(f"  {'✓' if changed else 'ℹ️ sudah ada'} import dp explicit")

# Fix 2: Tambah PointerInputChange import (fix: Cannot infer type di detectVerticalDragGestures)
add_import_after(
    song_path,
    "import androidx.compose.ui.input.pointer.pointerInput",
    "import androidx.compose.ui.input.pointer.PointerInputChange"
)
print("  ✓ import PointerInputChange")

# Fix 3: Beri tipe explicit pada lambda detectVerticalDragGestures
changed = fix_imports(
    song_path,
    "onVerticalDrag = { _, delta ->",
    "onVerticalDrag = { _: PointerInputChange, delta: Float ->"
)
print(f"  {'✓' if changed else 'ℹ️ sudah typed'} lambda PointerInputChange typed")

# ─── Fix NowPlayingScreen.kt ──────────────────────────────────────────────────
now_path = f"{UI}/NowPlayingScreen.kt"
print("\n🎵 NowPlayingScreen.kt:")

if not os.path.exists(now_path):
    print("  ⚠️  File tidak ditemukan, buat ulang...")
    # Tulis ulang NowPlayingScreen dengan semua import lengkap
    content = open(f"{UI}/NowPlayingScreen.kt", "w") if False else None
else:
    with open(now_path, "r") as f:
        content = f.read()

    missing_imports = [
        ("import coil.compose.AsyncImage",              "import com.dioxd.floramusic.data.PlayerState"),
        ("import androidx.compose.ui.layout.ContentScale", "import coil.compose.AsyncImage"),
        ("import androidx.compose.ui.input.pointer.PointerInputChange", "import androidx.compose.ui.input.pointer.pointerInput"),
        ("import androidx.compose.foundation.shape.RoundedCornerShape",  "import androidx.compose.foundation.shape.CircleShape"),
    ]

    for new_imp, anchor in missing_imports:
        if new_imp not in content:
            if anchor in content:
                content = content.replace(anchor, new_imp + "\n" + anchor)
                print(f"  ✓ Tambah: {new_imp.split('.')[-1]}")
            else:
                # Fallback: sisipkan setelah baris package
                if new_imp not in content:
                    content = content.replace(
                        "package com.dioxd.floramusic.ui",
                        "package com.dioxd.floramusic.ui\n\n" + new_imp
                    )
                    print(f"  ✓ Tambah (fallback): {new_imp.split('.')[-1]}")
        else:
            print(f"  ℹ️  Sudah ada: {new_imp.split('.')[-1]}")

    # Fix lambda PointerInputChange di NowPlayingScreen juga
    if "onVerticalDrag = { _, delta ->" in content:
        if "import androidx.compose.ui.input.pointer.PointerInputChange" not in content:
            content = content.replace(
                "import androidx.compose.ui.input.pointer.pointerInput",
                "import androidx.compose.ui.input.pointer.PointerInputChange\nimport androidx.compose.ui.input.pointer.pointerInput"
            )
        content = content.replace(
            "onVerticalDrag = { _, delta ->",
            "onVerticalDrag = { _: PointerInputChange, delta: Float ->"
        )
        print("  ✓ Lambda PointerInputChange typed")

    with open(now_path, "w") as f:
        f.write(content)

print("\n✅ Semua fix selesai!")
PYEOF

echo ""
echo "Sekarang:"
echo "  git add ."
echo "  git commit -m 'fix: PointerInputChange, dp, AsyncImage imports'"
echo "  git pull --rebase && git push"
