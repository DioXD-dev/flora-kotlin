package com.dioxd.floramusic.ui

import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.dioxd.floramusic.data.PlayerState
import com.dioxd.floramusic.data.Song

@Composable
fun FloraApp(
    songs:        List<Song>,
    onSongClick:  (Song, Int) -> Unit,
    onTogglePlay: () -> Unit,
    onNext:       () -> Unit,
    onPrev:       () -> Unit,
    seekTo:       (Int) -> Unit,
    progress:     Int,
    duration:     Int,
) {
    val nav = rememberNavController()

    NavHost(
        navController      = nav,
        startDestination   = "list",
        enterTransition    = { slideInVertically(tween(300)) { it } + fadeIn(tween(300)) },
        exitTransition     = { fadeOut(tween(200)) },
        popEnterTransition = { fadeIn(tween(200)) },
        popExitTransition  = { slideOutVertically(tween(300)) { it } + fadeOut(tween(300)) },
    ) {
        composable("list") {
            SongListScreen(
                songs             = songs,
                onSongClick       = { song, idx ->
                    onSongClick(song, idx)
                    nav.navigate("nowplaying")
                },
                onNowPlayingClick = {
                    if (PlayerState.currentSong != null) nav.navigate("nowplaying")
                },
                onTogglePlay = onTogglePlay,
                onNext       = onNext,
                onPrev       = onPrev,
                progress     = progress,
                duration     = duration,
            )
        }
        composable("nowplaying") {
            NowPlayingScreen(
                onBack       = { nav.popBackStack() },
                onNext       = onNext,
                onPrev       = onPrev,
                onTogglePlay = onTogglePlay,
                seekTo       = seekTo,
                progress     = progress,
                duration     = duration,
            )
        }
    }
}
