package com.dioxd.floramusic.ui

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.MusicRepository
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: SongAdapter
    private lateinit var searchAdapter: SongAdapter

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

        setupAdapters()
        setupMiniPlayer()
        setupSearch()
        checkPermission()

        // Update UI saat kembali dari NowPlaying
        PlayerState.onSongChanged = { song ->
            runOnUiThread {
                adapter.nowPlayingId = song.id
                searchAdapter.nowPlayingId = song.id
                updateMiniPlayer(song)
            }
        }
        PlayerState.onPlayStateChanged = { isPlaying ->
            runOnUiThread {
                binding.btnPlayPause.setImageResource(
                    if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
                )
            }
        }
    }

    private fun setupAdapters() {
        adapter = SongAdapter { song, index -> playSong(song, index) }
        binding.recyclerView.adapter = adapter

        searchAdapter = SongAdapter { song, index ->
            val realIndex = PlayerState.songs.indexOfFirst { it.id == song.id }
            playSong(song, realIndex)
            closeSearch()
        }
        binding.searchRecycler.adapter = searchAdapter
    }

    private fun setupMiniPlayer() {
        binding.miniPlayer.setOnClickListener {
            startActivity(Intent(this, NowPlayingActivity::class.java))
            overridePendingTransition(R.anim.slide_up, 0)
        }

        binding.btnPlayPause.setOnClickListener {
            PlayerState.mediaPlayer?.let {
                if (it.isPlaying) {
                    it.pause(); PlayerState.isPlaying = false
                } else {
                    it.start(); PlayerState.isPlaying = true
                }
                binding.btnPlayPause.setImageResource(
                    if (PlayerState.isPlaying) R.drawable.ic_pause else R.drawable.ic_play
                )
            }
        }

        binding.btnNext.setOnClickListener {
            val songs = PlayerState.songs
            if (songs.isEmpty()) return@setOnClickListener
            val next = (PlayerState.currentIndex + 1) % songs.size
            playSong(songs[next], next)
        }

        binding.btnPrev.setOnClickListener {
            val songs = PlayerState.songs
            if (songs.isEmpty()) return@setOnClickListener
            val prev = if (PlayerState.currentIndex <= 0) songs.size - 1 else PlayerState.currentIndex - 1
            playSong(songs[prev], prev)
        }
    }

    private fun setupSearch() {
        binding.btnSearch.setOnClickListener {
            binding.searchOverlay.visibility = View.VISIBLE
            binding.etSearch.requestFocus()
        }

        binding.btnCloseSearch.setOnClickListener { closeSearch() }

        binding.etSearch.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val query = s?.toString()?.lowercase() ?: ""
                val filtered = PlayerState.songs.filter {
                    it.title.lowercase().contains(query) ||
                    it.artist.lowercase().contains(query) ||
                    it.album.lowercase().contains(query)
                }
                searchAdapter.submitList(filtered)
            }
            override fun afterTextChanged(s: Editable?) {}
        })
    }

    private fun closeSearch() {
        binding.searchOverlay.visibility = View.GONE
        binding.etSearch.setText("")
    }

    private fun checkPermission() {
        val perm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.READ_MEDIA_AUDIO else Manifest.permission.READ_EXTERNAL_STORAGE
        if (ContextCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED)
            loadSongs() else permLauncher.launch(perm)
    }

    private fun loadSongs() {
        val songs = MusicRepository.getAllSongs(this)
        PlayerState.songs = songs
        adapter.submitList(songs)
        searchAdapter.submitList(songs)
        binding.tvSongCount.text = "${songs.size} lagu"
    }

    private fun playSong(song: Song, index: Int) {
        PlayerState.currentIndex = index
        PlayerState.mediaPlayer?.release()
        PlayerState.mediaPlayer = MediaPlayer().apply {
            setDataSource(applicationContext, song.uri)
            prepare()
            start()
            setOnCompletionListener {
                val next = (PlayerState.currentIndex + 1) % PlayerState.songs.size
                playSong(PlayerState.songs[next], next)
            }
        }
        PlayerState.isPlaying = true
        adapter.nowPlayingId = song.id
        searchAdapter.nowPlayingId = song.id
        updateMiniPlayer(song)
    }

    private fun updateMiniPlayer(song: Song) {
        binding.miniPlayerContainer.visibility = View.VISIBLE
        binding.tvNowTitle.text  = song.title
        binding.tvNowArtist.text = song.artist
        binding.btnPlayPause.setImageResource(R.drawable.ic_pause)
        Glide.with(this)
            .load(song.albumArtUri)
            .placeholder(R.drawable.ic_music_note)
            .error(R.drawable.ic_music_note)
            .centerCrop()
            .into(binding.imgNowArt)
    }

    override fun onResume() {
        super.onResume()
        // Sync state saat balik dari NowPlaying
        PlayerState.currentSong?.let {
            adapter.nowPlayingId = it.id
            binding.btnPlayPause.setImageResource(
                if (PlayerState.isPlaying) R.drawable.ic_pause else R.drawable.ic_play
            )
        }
    }
}
