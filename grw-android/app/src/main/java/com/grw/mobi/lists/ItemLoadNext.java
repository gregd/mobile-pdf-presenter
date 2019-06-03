package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.grw.mobi.R;
import com.grw.mobi.ui.LoadNextListener;

public class ItemLoadNext extends ARItem {

    LoadNextListener listener;

    public ItemLoadNext(Context context, LoadNextListener listener) {
        super(context, CATEGORY_LOAD_NEXT);
        this.listener = listener;
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent) {
        View v = inflater.inflate(R.layout.load_next_item, parent, false);
        return new LoadNextViewHolder(v);
    }

    @Override
    public void bindView(RecyclerView.ViewHolder viewHolder) {
        LoadNextViewHolder h = (LoadNextViewHolder) viewHolder;
        h.itemView.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (listener != null) {
            listener.loadNext();
        }
    }

    public static class LoadNextViewHolder extends RecyclerView.ViewHolder {
        public LoadNextViewHolder(View v) {
            super(v);
        }
    }

}
