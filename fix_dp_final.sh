#!/bin/bash
# Fix SongListScreen.kt — ganti wildcard unit.* dengan explicit imports
# Jalankan di dalam folder ~/flora-kotlin

FILE="app/src/main/java/com/dioxd/floramusic/ui/SongListScreen.kt"

if [ ! -f "$FILE" ]; then
    echo "❌ File tidak ditemukan: $FILE"
    exit 1
fi

python3 - << 'PYEOF'
FILE = "app/src/main/java/com/dioxd/floramusic/ui/SongListScreen.kt"

with open(FILE, "r") as f:
    content = f.read()

OLD = "import androidx.compose.ui.unit.*"
NEW = "import androidx.compose.ui.unit.dp\nimport androidx.compose.ui.unit.sp\nimport androidx.compose.ui.unit.TextUnit\nimport androidx.compose.ui.unit.DpSize"

if OLD in content:
    content = content.replace(OLD, NEW)
    with open(FILE, "w") as f:
        f.write(content)
    print("✅ Import berhasil diperbaiki!")
elif "import androidx.compose.ui.unit.dp" in content:
    print("ℹ️  Import dp sudah explicit, tidak perlu diubah.")
else:
    print("⚠️  Tidak menemukan import unit — cek file secara manual.")

PYEOF

echo ""
echo "Sekarang:"
echo "  git add ."
echo "  git commit -m 'fix: explicit dp import di SongListScreen'"
echo "  git pull --rebase && git push"
