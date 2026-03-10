package com.dioxd.floramusic.data

import android.media.MediaPlayer
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

object PlayerState {
    var songs:        List<Song>   by mutableStateOf(emptyList())
    var currentIndex: Int          by mutableIntStateOf(-1)
    var isPlaying:    Boolean      by mutableStateOf(false)
    var shuffle:      Boolean      by mutableStateOf(false)
    var repeat:       Boolean      by mutableStateOf(false)
    var progress:     Int          by mutableIntStateOf(0)
    var duration:     Int          by mutableIntStateOf(0)

    val currentSong: Song? get() = songs.getOrNull(currentIndex)

    var mediaPlayer: MediaPlayer? = null
}
