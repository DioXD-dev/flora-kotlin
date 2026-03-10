#!/bin/bash
# Flora Music - Material You Dynamic Color
# Jalankan di dalam folder ~/flora-kotlin
#
# Apa yang diubah:
#   1. SongAdapter.kt   — placeholder warna-warni per lagu
#   2. NowPlayingActivity.kt — ekstrak warna dari cover art, terapkan ke UI
#   3. DynamicThemeHelper.kt — helper palette Material You
#   4. PlayerState.kt   — tambah field shuffle & repeat
#   5. bg_album_art_color.xml — drawable placeholder warna

echo "🌿 Menerapkan Material You Dynamic Color..."

mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/java/com/dioxd/floramusic/ui
mkdir -p app/src/main/java/com/dioxd/floramusic/data

# ── 1. DynamicThemeHelper.kt ──────────────────────────────────────────────────
# Helper: ekstrak warna dominan dari Bitmap, generate palette Material You
cat > app/src/main/java/com/dioxd/floramusic/ui/DynamicThemeHelper.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.graphics.Bitmap
import android.graphics.Color
import androidx.palette.graphics.Palette

/**
 * Mengekstrak warna dominan dari cover art dan menghasilkan
 * set warna Material You (primary, container, surface, on-surface).
 */
object DynamicThemeHelper {

    data class DynamicColors(
        val primary: Int,          // Warna utama (aksen)
        val onPrimary: Int,        // Teks di atas primary
        val primaryContainer: Int, // Container — lebih terang
        val onPrimaryContainer: Int,
        val surface: Int,          // Background card/surface
        val onSurface: Int,        // Teks di atas surface
        val background: Int,       // Background halaman
    )

    // Warna fallback jika tidak ada cover art
    val fallback = DynamicColors(
        primary             = Color.parseColor("#E8A87C"),
        onPrimary           = Color.parseColor("#2a1500"),
        primaryContainer    = Color.parseColor("#4a2010"),
        onPrimaryContainer  = Color.parseColor("#FDEBD8"),
        surface             = Color.parseColor("#242019"),
        onSurface           = Color.parseColor("#F0EBE3"),
        background          = Color.parseColor("#1A1714"),
    )

    fun fromBitmap(bitmap: Bitmap): DynamicColors {
        val palette = Palette.from(bitmap).generate()

        // Ambil swatch terbaik — prioritas: Vibrant → Muted → DarkVibrant
        val swatch = palette.vibrantSwatch
            ?: palette.mutedSwatch
            ?: palette.darkVibrantSwatch
            ?: return fallback

        val primary = swatch.rgb
        val h = FloatArray(3)
        Color.colorToHSV(primary, h)

        // Buat turunan warna dari hue yang sama
        val primaryContainer = hsv(h[0], h[1] * 0.5f, 0.28f)
        val onPrimaryContainer = hsv(h[0], h[1] * 0.3f, 0.88f)
        val surface = hsv(h[0], h[1] * 0.25f, 0.14f)
        val background = hsv(h[0], h[1] * 0.20f, 0.09f)

        // onPrimary — hitam atau putih tergantung kecerahan primary
        val luminance = (0.299 * Color.red(primary) +
                         0.587 * Color.green(primary) +
                         0.114 * Color.blue(primary)) / 255.0
        val onPrimary = if (luminance > 0.45) Color.parseColor("#1a0e00")
                        else Color.parseColor("#FFFFFF")

        return DynamicColors(
            primary             = primary,
            onPrimary           = onPrimary,
            primaryContainer    = primaryContainer,
            onPrimaryContainer  = onPrimaryContainer,
            surface             = surface,
            onSurface           = Color.parseColor("#F0EBE3"),
            background          = background,
        )
    }

    private fun hsv(h: Float, s: Float, v: Float): Int {
        val arr = floatArrayOf(h, s.coerceIn(0f, 1f), v.coerceIn(0f, 1f))
        return Color.HSVToColor(arr)
    }
}
EOF
echo "  ✓ DynamicThemeHelper.kt"

# ── 2. SongAdapter.kt ─────────────────────────────────────────────────────────
# Placeholder warna-warni berdasarkan judul lagu (tidak perlu cover art)
cat > app/src/main/java/com/dioxd/floramusic/ui/SongAdapter.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
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

    companion object DiffCallback : DiffUtil.ItemCallback<Song>() {
        override fun areItemsTheSame(a: Song, b: Song) = a.id == b.id
        override fun areContentsTheSame(a: Song, b: Song) = a == b

        // Warm pastel — sama dengan warna di versi React Flora
        private val PLACEHOLDER_COLORS = listOf(
            0xFFB87840.toInt(), 0xFF7A6E88.toInt(), 0xFF5A9870.toInt(),
            0xFFB86060.toInt(), 0xFF5A84B8.toInt(), 0xFFB8980C.toInt(),
            0xFF8870A8.toInt(), 0xFF5CA4A0.toInt(), 0xFFA470A0.toInt(),
            0xFF7A9854.toInt(), 0xFFB87090.toInt(), 0xFF5A78B8.toInt(),
        )

        fun colorForSong(title: String): Int {
            val hash = title.fold(0) { acc, c -> acc * 31 + c.code }
            return PLACEHOLDER_COLORS[Math.abs(hash) % PLACEHOLDER_COLORS.size]
        }

        private fun darken(color: Int, factor: Float = 0.70f): Int {
            val r = (Color.red(color)   * factor).toInt().coerceIn(0, 255)
            val g = (Color.green(color) * factor).toInt().coerceIn(0, 255)
            val b = (Color.blue(color)  * factor).toInt().coerceIn(0, 255)
            return Color.argb(255, r, g, b)
        }

        fun roundedBg(color: Int): GradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(darken(color))
            cornerRadius = 42f   // ~14dp @ xxhdpi
        }
    }

    inner class SongViewHolder(private val binding: ItemSongBinding)
        : RecyclerView.ViewHolder(binding.root) {

        fun bind(song: Song, position: Int) {
            val isPlaying = song.id == nowPlayingId
            binding.tvTitle.text    = song.title
            binding.tvArtist.text   = song.artist
            binding.tvDuration.text = song.durationText
            binding.playingIndicator.visibility = if (isPlaying) View.VISIBLE else View.GONE
            binding.tvTitle.alpha   = if (isPlaying) 1f else 0.9f

            val placeholder = roundedBg(colorForSong(song.title))
            binding.imgAlbumArt.background = placeholder

            Glide.with(binding.imgAlbumArt)
                .load(song.albumArtUri)
                .placeholder(R.drawable.ic_music_note)
                .error(R.drawable.ic_music_note)
                .transition(DrawableTransitionOptions.withCrossFade())
                .centerCrop()
                .listener(object : RequestListener<android.graphics.drawable.Drawable> {
                    override fun onLoadFailed(
                        e: GlideException?, model: Any?,
                        target: Target<android.graphics.drawable.Drawable>,
                        isFirstResource: Boolean
                    ): Boolean {
                        binding.imgAlbumArt.background = placeholder
                        return false
                    }
                    override fun onResourceReady(
                        resource: android.graphics.drawable.Drawable,
                        model: Any,
                        target: Target<android.graphics.drawable.Drawable>?,
                        dataSource: DataSource,
                        isFirstResource: Boolean
                    ): Boolean {
                        binding.imgAlbumArt.background = null
                        return false
                    }
                })
                .into(binding.imgAlbumArt)

            binding.root.setOnClickListener { onSongClick(song, position) }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        SongViewHolder(ItemSongBinding.inflate(LayoutInflater.from(parent.context), parent, false))

    override fun onBindViewHolder(holder: SongViewHolder, position: Int) =
        holder.bind(getItem(position), position)
}
EOF
echo "  ✓ SongAdapter.kt"

# ── 3. PlayerState.kt ─────────────────────────────────────────────────────────
# Tambah field shuffle & repeat
cat > app/src/main/java/com/dioxd/floramusic/data/PlayerState.kt << 'EOF'
package com.dioxd.floramusic.data

import android.media.MediaPlayer

object PlayerState {
    var mediaPlayer: MediaPlayer?  = null
    var songs: List<Song>          = emptyList()
    var currentIndex: Int          = -1
    var isPlaying: Boolean         = false
    var shuffle: Boolean           = false
    var repeat: Boolean            = false

    val currentSong: Song?
        get() = songs.getOrNull(currentIndex)

    var onSongChanged: ((Song) -> Unit)?        = null
    var onPlayStateChanged: ((Boolean) -> Unit)? = null

    fun nextIndex(): Int {
        if (songs.isEmpty()) return 0
        return if (shuffle) (songs.indices - currentIndex).random()
        else (currentIndex + 1) % songs.size
    }

    fun prevIndex(): Int {
        if (songs.isEmpty()) return 0
        return if (currentIndex <= 0) songs.size - 1
        else currentIndex - 1
    }
}
EOF
echo "  ✓ PlayerState.kt"

# ── 4. NowPlayingActivity.kt ─────────────────────────────────────────────────
# Terapkan DynamicColors ke seekbar, tombol play, teks artis, background
cat > app/src/main/java/com/dioxd/floramusic/ui/NowPlayingActivity.kt << 'EOF'
package com.dioxd.floramusic.ui

import android.content.res.ColorStateList
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.PorterDuff
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.LayerDrawable
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import android.view.animation.DecelerateInterpolator
import android.widget.SeekBar
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.bumptech.glide.Glide
import com.bumptech.glide.request.target.CustomTarget
import com.bumptech.glide.request.transition.Transition
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ActivityNowPlayingBinding

class NowPlayingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityNowPlayingBinding
    private val handler  = Handler(Looper.getMainLooper())
    private var isSeeking = false
    private var isLiked   = false

    // Swipe-down dismiss
    private var touchStartY      = 0f
    private var isDragging       = false
    private val DISMISS_THRESHOLD = 220f

    private val updateProgress = object : Runnable {
        override fun run() {
            PlayerState.mediaPlayer?.let { mp ->
                if (!isSeeking && mp.isPlaying) {
                    val pos = mp.currentPosition
                    val dur = mp.duration
                    if (dur > 0) {
                        binding.seekBar.max      = dur
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
        window.statusBarColor = Color.TRANSPARENT

        setupControls()
        setupPills()
        setupSwipeToDismiss()
        updateUI(PlayerState.currentSong)
        handler.post(updateProgress)
    }

    // ── Muat cover art → ekstrak warna → terapkan ke UI ──────────────────────
    private fun updateUI(song: Song?) {
        song ?: return
        binding.tvTitle.text  = song.title
        binding.tvArtist.text = song.artist
        updatePlayButton()

        Glide.with(this)
            .asBitmap()
            .load(song.albumArtUri)
            .into(object : CustomTarget<Bitmap>() {
                override fun onResourceReady(bmp: Bitmap, t: Transition<in Bitmap>?) {
                    binding.imgAlbumArt.setImageBitmap(bmp)
                    applyBlurredBg(bmp)

                    // ── Material You: ekstrak warna dari cover ────────────
                    val colors = DynamicThemeHelper.fromBitmap(bmp)
                    applyDynamicColors(colors)
                }

                override fun onLoadFailed(err: Drawable?) {
                    binding.imgBgBlur.setImageDrawable(null)
                    binding.imgBgBlur.setBackgroundColor(Color.parseColor("#2d2420"))
                    binding.imgAlbumArt.setImageResource(R.drawable.ic_music_note)

                    // Warna fallback dari judul lagu (sama seperti SongAdapter)
                    val seed = SongAdapter.colorForSong(song.title)
                    val bg   = GradientDrawable().apply {
                        shape = GradientDrawable.RECTANGLE
                        setColor(seed and 0x00FFFFFF or 0x55000000)
                        cornerRadius = 60f
                    }
                    binding.imgAlbumArt.background = bg
                    applyDynamicColors(DynamicThemeHelper.fallback)
                }

                override fun onLoadCleared(p: Drawable?) {}
            })
    }

    // ── Terapkan DynamicColors ke semua elemen UI ─────────────────────────────
    private fun applyDynamicColors(c: DynamicThemeHelper.DynamicColors) {
        // Warna artis
        binding.tvArtist.setTextColor(c.primary)

        // Seekbar — progress & thumb
        binding.seekBar.progressTintList         = ColorStateList.valueOf(c.primary)
        binding.seekBar.thumbTintList            = ColorStateList.valueOf(c.primary)
        binding.seekBar.progressBackgroundTintList =
            ColorStateList.valueOf(Color.argb(68, 255, 255, 255))

        // Tombol play/pause — ganti warna background lingkaran
        val playBg = binding.btnPlayPause.parent as? android.widget.FrameLayout
        playBg?.getChildAt(0)?.let { glow ->
            // bg_play_accent layer-list: layer ke-2 (indeks 2) adalah lingkaran utama
            val layers = glow.background as? LayerDrawable
            layers?.let {
                for (i in 0 until it.numberOfLayers) {
                    (it.getDrawable(i) as? GradientDrawable)?.setColor(
                        when (i) {
                            0    -> Color.argb(48,  Color.red(c.primary), Color.green(c.primary), Color.blue(c.primary))
                            1    -> Color.argb(85,  Color.red(c.primary), Color.green(c.primary), Color.blue(c.primary))
                            else -> c.primary
                        }
                    )
                }
            }
        }

        // Skip prev/next tint
        binding.btnPrev.setColorFilter(c.primary, PorterDuff.Mode.SRC_IN)
        binding.btnNext.setColorFilter(c.primary, PorterDuff.Mode.SRC_IN)

        // Like button tint (saat aktif)
        if (isLiked) binding.btnLike.setColorFilter(c.primary, PorterDuff.Mode.SRC_IN)

        // Pill bar background — tint tipis warna primer
        val pillAlpha = Color.argb(55, Color.red(c.primary), Color.green(c.primary), Color.blue(c.primary))
        val pillBg = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 1000f
            setColor(pillAlpha)
        }
        binding.pillBar.background = pillBg
    }

    // ── Blur background dari cover art ────────────────────────────────────────
    private fun applyBlurredBg(bmp: Bitmap) {
        // Buat versi kecil lalu scale up = efek blur murah
        val small = Bitmap.createScaledBitmap(bmp, 32, 32, true)
        val blurred = Bitmap.createScaledBitmap(small, bmp.width, bmp.height, true)
        binding.imgBgBlur.setImageBitmap(blurred)
        small.recycle()
    }

    // ── Swipe-down untuk dismiss ──────────────────────────────────────────────
    private fun setupSwipeToDismiss() {
        binding.albumArtContainer.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN  -> { touchStartY = event.rawY; isDragging = false; false }
                MotionEvent.ACTION_MOVE  -> {
                    val dy = event.rawY - touchStartY
                    if (dy > 10f) {
                        isDragging = true
                        binding.contentLayout.translationY = dy.coerceAtMost(400f)
                        binding.contentLayout.alpha        = 1f - (dy.coerceAtMost(400f) / 500f)
                        true
                    } else false
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    val dy = event.rawY - touchStartY
                    if (isDragging && dy > DISMISS_THRESHOLD) {
                        binding.contentLayout.animate()
                            .translationY(binding.root.height.toFloat()).alpha(0f)
                            .setDuration(220).setInterpolator(DecelerateInterpolator())
                            .withEndAction { finish() }.start()
                    } else {
                        binding.contentLayout.animate()
                            .translationY(0f).alpha(1f)
                            .setDuration(300).setInterpolator(DecelerateInterpolator()).start()
                    }
                    true
                }
                else -> false
            }
        }
    }

    private fun setupControls() {
        binding.btnClose.setOnClickListener {
            binding.contentLayout.animate()
                .translationY(binding.root.height.toFloat()).alpha(0f).setDuration(220)
                .withEndAction { finish() }.start()
        }

        binding.btnSettings.setOnClickListener {
            Toast.makeText(this, "⚙️ Pengaturan (coming soon)", Toast.LENGTH_SHORT).show()
        }

        binding.btnLike.setOnClickListener {
            isLiked = !isLiked
            binding.btnLike.setImageResource(
                if (isLiked) R.drawable.ic_heart_filled else R.drawable.ic_heart
            )
        }

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

        binding.btnNext.setOnClickListener { playAt(PlayerState.nextIndex()) }
        binding.btnPrev.setOnClickListener { playAt(PlayerState.prevIndex()) }

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
            binding.pillShuffle.alpha = if (PlayerState.shuffle) 1f else 0.5f
        }
        binding.pillRepeat.setOnClickListener {
            PlayerState.repeat = !PlayerState.repeat
            binding.pillRepeat.alpha = if (PlayerState.repeat) 1f else 0.5f
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

    private fun playAt(index: Int) {
        if (PlayerState.songs.isEmpty()) return
        val song = PlayerState.songs[index]
        PlayerState.currentIndex = index
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = MediaPlayer().apply {
            setDataSource(applicationContext, song.uri)
            prepare(); start()
            setOnCompletionListener {
                if (PlayerState.repeat) { seekTo(0); start() }
                else playAt(PlayerState.nextIndex())
            }
        }
        PlayerState.isPlaying = true
        updateUI(song)
        PlayerState.onSongChanged?.invoke(song)
    }

    private fun updatePlayButton() {
        val playing = PlayerState.mediaPlayer?.isPlaying == true
        binding.btnPlayPause.setImageResource(
            if (playing) R.drawable.ic_pause_dark else R.drawable.ic_play_dark
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
echo "  ✓ NowPlayingActivity.kt"

# ── 5. Tambah dependency Palette ke build.gradle ──────────────────────────────
# Cek apakah sudah ada
if ! grep -q "palette" app/build.gradle; then
    # Sisipkan sebelum baris penutup dependencies {}
    sed -i '/^}/i\    implementation "androidx.palette:palette-ktx:1.0.0"' app/build.gradle
    echo "  ✓ Palette dependency ditambahkan ke app/build.gradle"
else
    echo "  ✓ Palette dependency sudah ada"
fi

# ── Selesai ───────────────────────────────────────────────────────────────────
echo ""
echo "✅ Material You Dynamic Color berhasil diterapkan!"
echo ""
echo "File yang diubah:"
echo "  + DynamicThemeHelper.kt  — ekstrak warna dari Bitmap (Palette API)"
echo "  ~ SongAdapter.kt         — placeholder warna-warni per lagu"
echo "  ~ PlayerState.kt         — tambah shuffle & repeat"
echo "  ~ NowPlayingActivity.kt  — apply warna ke seekbar, tombol, pill"
echo ""
echo "Jalankan sekarang:"
echo "  git add ."
echo "  git commit -m 'feat: Material You dynamic color dari cover art'"
echo "  git pull --rebase && git push"
