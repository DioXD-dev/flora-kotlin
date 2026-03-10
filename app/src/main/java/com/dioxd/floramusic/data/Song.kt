package com.dioxd.floramusic.data

import android.net.Uri

data class Song(
    val id: Long,
    val title: String,
    val artist: String,
    val album: String,
    val duration: Long,
    val uri: Uri,
    val albumId: Long
) {
    val durationText: String get() {
        val m = duration / 1000 / 60
        val s = (duration / 1000) % 60
        return "%d:%02d".format(m, s)
    }
    val albumArtUri: Uri get() =
        Uri.parse("content://media/external/audio/albumart/$albumId")
}
