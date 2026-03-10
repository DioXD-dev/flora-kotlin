#!/bin/bash
# Fix: Unresolved reference: dp — menggunakan Python (lebih reliable di Termux)
# Jalankan di dalam folder ~/flora-kotlin

FILE="app/src/main/java/com/dioxd/floramusic/ui/SongListScreen.kt"

if [ ! -f "$FILE" ]; then
    echo "❌ File tidak ditemukan: $FILE"
    exit 1
fi

echo "🔧 Memperbaiki import dp di SongListScreen.kt..."

python3 << PYEOF
import re

with open("$FILE", "r") as f:
    content = f.read()

# Cek apakah explicit import sudah ada
if "import androidx.compose.ui.unit.dp" in content:
    print("  ℹ️  Import dp sudah ada, skip.")
else:
    # Ganti wildcard unit.* dengan explicit imports
    content = content.replace(
        "import androidx.compose.ui.unit.*",
        "import androidx.compose.ui.unit.*\nimport androidx.compose.ui.unit.dp\nimport androidx.compose.ui.unit.sp\nimport androidx.compose.ui.unit.TextUnit"
    )
    with open("$FILE", "w") as f:
        f.write(content)
    print("  ✓ Import dp berhasil ditambahkan")

PYEOF

echo ""
echo "✅ Fix selesai. Sekarang:"
echo "  git add ."
echo "  git commit -m 'fix: explicit dp import (Termux sed workaround)'"
echo "  git pull --rebase && git push"
