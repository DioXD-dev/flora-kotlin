package com.dioxd.floramusic.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.drawable.DrawableTransitionOptions
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

    inner class SongViewHolder(private val binding: ItemSongBinding)
        : RecyclerView.ViewHolder(binding.root) {
        fun bind(song: Song, position: Int) {
            binding.tvTitle.text    = song.title
            binding.tvArtist.text   = song.artist
            binding.tvDuration.text = song.durationText
            binding.root.isActivated = song.id == nowPlayingId
            Glide.with(binding.imgAlbumArt)
                .load(song.albumArtUri)
                .placeholder(R.drawable.ic_music_note)
                .error(R.drawable.ic_music_note)
                .transition(DrawableTransitionOptions.withCrossFade())
                .centerCrop()
                .into(binding.imgAlbumArt)
            binding.root.setOnClickListener { onSongClick(song, position) }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        SongViewHolder(ItemSongBinding.inflate(LayoutInflater.from(parent.context), parent, false))

    override fun onBindViewHolder(holder: SongViewHolder, position: Int) =
        holder.bind(getItem(position), position)

    companion object DiffCallback : DiffUtil.ItemCallback<Song>() {
        override fun areItemsTheSame(a: Song, b: Song) = a.id == b.id
        override fun areContentsTheSame(a: Song, b: Song) = a == b
    }
}
