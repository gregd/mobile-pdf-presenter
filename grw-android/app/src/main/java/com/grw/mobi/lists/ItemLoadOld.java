package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.grw.mobi.R;
import com.grw.mobi.ui.LoadOldListener;

public class ItemLoadOld extends ARItem {

    LoadOldListener listener;
    LoadOldViewHolder holder;

    public ItemLoadOld(Context context, LoadOldListener listener) {
        super(context, CATEGORY_LOAD_OLD);
        this.listener = listener;
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent) {
        View v = inflater.inflate(R.layout.load_old_item, parent, false);
        return new LoadOldViewHolder(v);
    }

    @Override
    public void bindView(RecyclerView.ViewHolder viewHolder) {
        LoadOldViewHolder h = (LoadOldViewHolder) viewHolder;
        h.itemView.setOnClickListener(this);
        holder = h;
    }

    @Override
    public void onClick(View v) {
        if (listener != null && holder != null) {
            holder.message.setVisibility(View.INVISIBLE);
            holder.progressBar.setVisibility(View.VISIBLE);
            listener.loadOld();
        }
    }

    public static class LoadOldViewHolder extends RecyclerView.ViewHolder {
        TextView message;
        ProgressBar progressBar;

        public LoadOldViewHolder(View v) {
            super(v);
            message = (TextView) v.findViewById(R.id.load_old_item_message);
            progressBar = (ProgressBar) v.findViewById(R.id.load_old_item_progress);
        }
    }

}

