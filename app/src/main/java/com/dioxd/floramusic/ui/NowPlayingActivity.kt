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
