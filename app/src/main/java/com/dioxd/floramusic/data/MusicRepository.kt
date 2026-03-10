package com.dioxd.floramusic.data

import android.content.Context
import android.net.Uri
import android.provider.MediaStore

object MusicRepository {
    fun getAllSongs(context: Context): List<Song> {
        val songs = mutableListOf<Song>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.ALBUM_ID,
        )
        val selection =
            "${MediaStore.Audio.Media.IS_MUSIC} != 0 " +
            "AND ${MediaStore.Audio.Media.DURATION} > 30000"

        context.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection, selection, null,
            "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC",
        )?.use { c ->
            val iId  = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val iTit = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val iArt = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val iAlb = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val iDur = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val iAid = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            while (c.moveToNext()) {
                val id = c.getLong(iId)
                songs += Song(
                    id       = id,
                    title    = c.getString(iTit) ?: "Unknown",
                    artist   = c.getString(iArt)?.takeIf { it != "<unknown>" } ?: "Unknown Artist",
                    album    = c.getString(iAlb)?.takeIf { it != "<unknown>" } ?: "Unknown Album",
                    duration = c.getLong(iDur),
                    uri      = Uri.withAppendedPath(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id.toString()),
                    albumId  = c.getLong(iAid),
                )
            }
        }
        return songs
    }
}
