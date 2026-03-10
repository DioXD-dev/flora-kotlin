package com.dioxd.floramusic.ui

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.core.content.ContextCompat
import com.dioxd.floramusic.data.MusicRepository
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.ui.theme.FloraTheme

class MainActivity : ComponentActivity() {

    private var songs    by mutableStateOf(emptyList<Song>())
    private var progress by mutableIntStateOf(0)
    private var duration by mutableIntStateOf(0)

    private val handler = Handler(Looper.getMainLooper())
    private val progressUpdater = object : Runnable {
        override fun run() {
            PlayerState.mediaPlayer?.let {
                progress = it.currentPosition
                duration = it.duration
            }
            handler.postDelayed(this, 500)
        }
    }

    private val permLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted -> if (granted) loadSongs() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            FloraTheme {
                FloraApp(
                    songs        = songs,
                    onSongClick  = ::playSong,
                    onTogglePlay = ::togglePlay,
                    onNext       = ::playNext,
                    onPrev       = ::playPrev,
                    seekTo       = ::seekTo,
                    progress     = progress,
                    duration     = duration,
                )
            }
        }

        checkPermission()
        handler.post(progressUpdater)
    }

    private fun checkPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.READ_MEDIA_AUDIO
        else
            Manifest.permission.READ_EXTERNAL_STORAGE

        if (ContextCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED)
            loadSongs()
        else
            permLauncher.launch(perm)
    }

    private fun loadSongs() {
        songs = MusicRepository.getAllSongs(this)
        PlayerState.songs = songs
    }

    private fun playSong(song: Song, index: Int) {
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
    }

    private fun togglePlay() {
        PlayerState.mediaPlayer?.let {
            if (it.isPlaying) { it.pause(); PlayerState.isPlaying = false }
            else              { it.start(); PlayerState.isPlaying = true  }
        }
    }

    private fun playNext() {
        val s = PlayerState.songs
        if (s.isEmpty()) return
        val next = if (PlayerState.shuffle)
            (0 until s.size).random()
        else
            (PlayerState.currentIndex + 1) % s.size
        playSong(s[next], next)
    }

    private fun playPrev() {
        val s = PlayerState.songs
        if (s.isEmpty()) return
        val prev = if (PlayerState.currentIndex <= 0) s.size - 1
                   else PlayerState.currentIndex - 1
        playSong(s[prev], prev)
    }

    private fun seekTo(ms: Int) {
        PlayerState.mediaPlayer?.seekTo(ms)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(progressUpdater)
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = null
    }
}
