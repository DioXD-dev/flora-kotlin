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

        // Warna-warna warm pastel seperti versi React Flora
        private val PLACEHOLDER_COLORS = listOf(
            0xFFE8A87C.toInt(), // oranye hangat
            0xFF9B8EA8.toInt(), // ungu soft
            0xFF7EC8A0.toInt(), // hijau mint
            0xFFE88C8C.toInt(), // merah rose
            0xFF8CB4E8.toInt(), // biru muda
            0xFFE8C87C.toInt(), // kuning warm
            0xFFB8A0D8.toInt(), // lavender
            0xFF8CD4C8.toInt(), // teal soft
            0xFFD4A0B8.toInt(), // pink dusty
            0xFFA8C87C.toInt(), // hijau sage
            0xFFE8A0B8.toInt(), // pink warm
            0xFF7CA8E8.toInt(), // biru cornflower
        )

        fun colorForSong(title: String): Int {
            val hash = title.fold(0) { acc, c -> acc * 31 + c.code }
            return PLACEHOLDER_COLORS[Math.abs(hash) % PLACEHOLDER_COLORS.size]
        }

        fun darkenColor(color: Int, factor: Float = 0.70f): Int {
            val r = (Color.red(color) * factor).toInt().coerceIn(0, 255)
            val g = (Color.green(color) * factor).toInt().coerceIn(0, 255)
            val b = (Color.blue(color) * factor).toInt().coerceIn(0, 255)
            return Color.argb(255, r, g, b)
        }

        fun makeRoundedBackground(color: Int, radiusDp: Float = 14f): GradientDrawable {
            return GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                setColor(color)
                cornerRadius = radiusDp * 3f
            }
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
            binding.tvTitle.alpha = if (isPlaying) 1f else 0.9f

            val placeholderColor = darkenColor(colorForSong(song.title))
            val roundedBg = makeRoundedBackground(placeholderColor)

            // Set placeholder background dulu
            binding.imgAlbumArt.background = roundedBg

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
                        // Tidak ada album art — tetap pakai warna
                        binding.imgAlbumArt.background = roundedBg
                        return false
                    }
                    override fun onResourceReady(
                        resource: android.graphics.drawable.Drawable,
                        model: Any,
                        target: Target<android.graphics.drawable.Drawable>?,
                        dataSource: DataSource,
                        isFirstResource: Boolean
                    ): Boolean {
                        // Ada album art — hapus warna background
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
