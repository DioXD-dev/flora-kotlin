package com.dioxd.floramusic.ui

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
import com.dioxd.floramusic.R
import com.dioxd.floramusic.data.Song
import com.dioxd.floramusic.databinding.ItemSongBinding

class SongAdapter(
    private val onSongClick: (Song, Int) -> Unit
) : ListAdapter<Song, SongAdapter.SongViewHolder>(DiffCallback) {

    var nowPlayingId: Long = -1L
        set(value) {
            val old = currentList.indexOfFirst { it.id == field }
            val new = currentList.indexOfFirst { it.id == value }
            field = value
            if (old >= 0) notifyItemChanged(old)
            if (new >= 0) notifyItemChanged(new)
        }

    companion object DiffCallback : DiffUtil.ItemCallback<Song>() {
        override fun areItemsTheSame(a: Song, b: Song) = a.id == b.id
        override fun areContentsTheSame(a: Song, b: Song) = a == b

        // Warm pastel — sama dengan warna di versi React Flora
        private val PLACEHOLDER_COLORS = listOf(
            0xFFB87840.toInt(), 0xFF7A6E88.toInt(), 0xFF5A9870.toInt(),
            0xFFB86060.toInt(), 0xFF5A84B8.toInt(), 0xFFB8980C.toInt(),
            0xFF8870A8.toInt(), 0xFF5CA4A0.toInt(), 0xFFA470A0.toInt(),
            0xFF7A9854.toInt(), 0xFFB87090.toInt(), 0xFF5A78B8.toInt(),
        )

        fun colorForSong(title: String): Int {
            val hash = title.fold(0) { acc, c -> acc * 31 + c.code }
            return PLACEHOLDER_COLORS[Math.abs(hash) % PLACEHOLDER_COLORS.size]
        }

        private fun darken(color: Int, factor: Float = 0.70f): Int {
            val r = (Color.red(color)   * factor).toInt().coerceIn(0, 255)
            val g = (Color.green(color) * factor).toInt().coerceIn(0, 255)
            val b = (Color.blue(color)  * factor).toInt().coerceIn(0, 255)
            return Color.argb(255, r, g, b)
        }

        fun roundedBg(color: Int): GradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(darken(color))
            cornerRadius = 42f   // ~14dp @ xxhdpi
        }
    }

    inner class SongViewHolder(private val binding: ItemSongBinding)
        : RecyclerView.ViewHolder(binding.root) {

        fun bind(song: Song, position: Int) {
            val isPlaying = song.id == nowPlayingId
            binding.tvTitle.text    = song.title
            binding.tvArtist.text   = song.artist
            binding.tvDuration.text = song.durationText
            binding.playingIndicator.visibility = if (isPlaying) View.VISIBLE else View.GONE
            binding.tvTitle.alpha   = if (isPlaying) 1f else 0.9f

            val placeholder = roundedBg(colorForSong(song.title))
            binding.imgAlbumArt.background = placeholder

            Glide.with(binding.imgAlbumArt)
                .load(song.albumArtUri)
                .placeholder(R.drawable.ic_music_note)
                .error(R.drawable.ic_music_note)
                .transition(DrawableTransitionOptions.withCrossFade())
                .centerCrop()
                .listener(object : RequestListener<android.graphics.drawable.Drawable> {
                    override fun onLoadFailed(
                        e: GlideException?, model: Any?,
                        target: Target<android.graphics.drawable.Drawable>,
                        isFirstResource: Boolean
                    ): Boolean {
                        binding.imgAlbumArt.background = placeholder
                        return false
                    }
                    override fun onResourceReady(
                        resource: android.graphics.drawable.Drawable,
                        model: Any,
                        target: Target<android.graphics.drawable.Drawable>?,
                        dataSource: DataSource,
                        isFirstResource: Boolean
                    ): Boolean {
                        binding.imgAlbumArt.background = null
                        return false
                    }
                })
                .into(binding.imgAlbumArt)

            binding.root.setOnClickListener { onSongClick(song, position) }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        SongViewHolder(ItemSongBinding.inflate(LayoutInflater.from(parent.context), parent, false))

    override fun onBindViewHolder(holder: SongViewHolder, position: Int) =
        holder.bind(getItem(position), position)
}
