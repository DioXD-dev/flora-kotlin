package com.dioxd.floramusic.ui

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.MusicRepository
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: SongAdapter
    private var mediaPlayer: MediaPlayer? = null
    private var songs: List<Song> = emptyList()
    private var currentIndex = -1

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
        adapter = SongAdapter { song, index -> playSong(song, index) }
        binding.recyclerView.adapter = adapter
        binding.recyclerView.setHasFixedSize(true)
        binding.btnPlayPause.setOnClickListener {
            mediaPlayer?.let { if (it.isPlaying) pauseSong() else resumeSong() }
        }
        binding.btnNext.setOnClickListener { playNext() }
        binding.btnPrev.setOnClickListener { playPrev() }
        checkPermission()
    }

    private fun checkPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.READ_MEDIA_AUDIO else Manifest.permission.READ_EXTERNAL_STORAGE
        if (ContextCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED)
            loadSongs() else permLauncher.launch(perm)
    }

    private fun loadSongs() {
        songs = MusicRepository.getAllSongs(this)
        adapter.submitList(songs)
        binding.tvSongCount.text = "${songs.size} lagu"
    }

    private fun playSong(song: Song, index: Int) {
        currentIndex = index
        mediaPlayer?.release()
        mediaPlayer = MediaPlayer().apply {
            setDataSource(applicationContext, song.uri)
            prepare(); start()
            setOnCompletionListener { playNext() }
        }
        adapter.nowPlayingId = song.id
        binding.tvNowTitle.text  = song.title
        binding.tvNowArtist.text = song.artist
        binding.btnPlayPause.setIconResource(R.drawable.ic_pause)
        Glide.with(this).load(song.albumArtUri)
            .placeholder(R.drawable.ic_music_note).error(R.drawable.ic_music_note)
            .centerCrop().into(binding.imgNowArt)
    }

    private fun pauseSong()  { mediaPlayer?.pause(); binding.btnPlayPause.setIconResource(R.drawable.ic_play) }
    private fun resumeSong() { mediaPlayer?.start(); binding.btnPlayPause.setIconResource(R.drawable.ic_pause) }
    private fun playNext() { if (songs.isEmpty()) return; val i = (currentIndex + 1) % songs.size; playSong(songs[i], i) }
    private fun playPrev() { if (songs.isEmpty()) return; val i = if (currentIndex <= 0) songs.size - 1 else currentIndex - 1; playSong(songs[i], i) }

    override fun onDestroy() { super.onDestroy(); mediaPlayer?.release() }
}
