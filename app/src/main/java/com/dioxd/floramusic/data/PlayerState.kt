package com.dioxd.floramusic.data

import android.media.MediaPlayer
import com.dioxd.floramusic.data.Song

object PlayerState {
    var mediaPlayer: MediaPlayer? = null
    var songs: List<Song> = emptyList()
    var currentIndex: Int = -1
    var isPlaying: Boolean = false
    var shuffle: Boolean = false
    var repeat: Boolean = false

    val currentSong: Song? get() = songs.getOrNull(currentIndex)

    var onSongChanged: ((Song) -> Unit)? = null
    var onPlayStateChanged: ((Boolean) -> Unit)? = null
}
