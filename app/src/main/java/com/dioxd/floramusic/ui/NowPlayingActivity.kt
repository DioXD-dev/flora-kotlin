package com.dioxd.floramusic.ui

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.Drawable
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
import jp.wasabeef.blurry.Blurry

class NowPlayingActivity : AppCompatActivity() {

    private lateinit var binding: ActivityNowPlayingBinding
    private val handler = Handler(Looper.getMainLooper())
    private var isSeeking = false
    private var isLiked = false

    // ── Swipe-down untuk tutup ────────────────────────────────────────────────
    private var touchStartY = 0f
    private var isDragging  = false
    private val DISMISS_THRESHOLD = 220f

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
        window.statusBarColor = Color.TRANSPARENT

        updateUI(PlayerState.currentSong)
        setupControls()
        setupPills()
        setupSwipeToDismiss()
        handler.post(updateProgress)
    }

    // ── Swipe-down pada cover art ─────────────────────────────────────────────
    private fun setupSwipeToDismiss() {
        binding.albumArtContainer.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    touchStartY = event.rawY
                    isDragging  = false
                    false
                }
                MotionEvent.ACTION_MOVE -> {
                    val dy = event.rawY - touchStartY
                    if (dy > 10) {
                        isDragging = true
                        // Ikuti jari — translasi seluruh konten
                        val clamped = dy.coerceAtMost(400f)
                        binding.contentLayout.translationY = clamped
                        binding.contentLayout.alpha = 1f - (clamped / 500f)
                        true
                    } else false
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    val dy = event.rawY - touchStartY
                    if (isDragging && dy > DISMISS_THRESHOLD) {
                        // Tutup dengan animasi
                        binding.contentLayout.animate()
                            .translationY(binding.root.height.toFloat())
                            .alpha(0f)
                            .setDuration(220)
                            .setInterpolator(DecelerateInterpolator())
                            .withEndAction { finish() }
                            .start()
                    } else {
                        // Snap kembali
                        binding.contentLayout.animate()
                            .translationY(0f)
                            .alpha(1f)
                            .setDuration(300)
                            .setInterpolator(DecelerateInterpolator())
                            .start()
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
                .translationY(binding.root.height.toFloat())
                .alpha(0f)
                .setDuration(220)
                .withEndAction { finish() }
                .start()
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
            else PlayerState.currentIndex - 1
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
        // Toggle shuffle
        binding.pillShuffle.setOnClickListener {
            PlayerState.shuffle = !PlayerState.shuffle
            binding.pillShuffle.alpha = if (PlayerState.shuffle) 1f else 0.5f
            binding.pillShuffle.setColorFilter(
                if (PlayerState.shuffle) Color.parseColor("#E8A87C") else Color.WHITE
            )
        }

        // Toggle repeat
        binding.pillRepeat.setOnClickListener {
            PlayerState.repeat = !PlayerState.repeat
            binding.pillRepeat.alpha = if (PlayerState.repeat) 1f else 0.5f
            binding.pillRepeat.setColorFilter(
                if (PlayerState.repeat) Color.parseColor("#E8A87C") else Color.WHITE
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

        // Load album art + blur bg
        Glide.with(this)
            .asBitmap()
            .load(song.albumArtUri)
            .into(object : CustomTarget<Bitmap>() {
                override fun onResourceReady(bitmap: Bitmap, transition: Transition<in Bitmap>?) {
                    binding.imgAlbumArt.setImageBitmap(bitmap)
                    Blurry.with(applicationContext)
                        .radius(22).sampling(4)
                        .from(bitmap)
                        .into(binding.imgBgBlur)
                }

                override fun onLoadFailed(errorDrawable: Drawable?) {
                    // Tidak ada cover — background solid dark + aksen subtle
                    binding.imgBgBlur.setImageDrawable(null)
                    binding.imgBgBlur.setBackgroundColor(Color.parseColor("#2d2420"))
                    binding.imgAlbumArt.setImageResource(R.drawable.ic_music_note)
                    binding.imgAlbumArt.setBackgroundColor(Color.parseColor("#3d3028"))
                }

                override fun onLoadCleared(placeholder: Drawable?) {}
            })
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
