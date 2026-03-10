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
