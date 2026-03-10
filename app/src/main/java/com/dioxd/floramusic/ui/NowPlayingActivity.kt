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
