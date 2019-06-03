package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.grw.mobi.R;

public class ItemMessage extends ARItem {
    private String title;
    private String description;

    public ItemMessage(Context context, String title, String description) {
        super(context, CATEGORY_MESSAGE);
        this.title = title;
        this.description = description;
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent) {
        View v = inflater.inflate(R.layout.message_item, parent, false);
        return new MessageViewHolder(v);
    }

    @Override
    public void bindView(RecyclerView.ViewHolder viewHolder) {
        MessageViewHolder h = (MessageViewHolder) viewHolder;

        if (title != null) {
            h.titleView.setText(title);
            h.titleView.setVisibility(View.VISIBLE);
        } else {
            h.titleView.setVisibility(View.GONE);
        }
        if (description != null) {
            h.descriptionView.setText(description);
            h.descriptionView.setVisibility(View.VISIBLE);
        } else {
            h.descriptionView.setVisibility(View.GONE);
        }
    }

    public static class MessageViewHolder extends RecyclerView.ViewHolder {
        TextView titleView;
        TextView descriptionView;

        public MessageViewHolder(View v) {
            super(v);
            titleView = (TextView) v.findViewById(R.id.message_title);
            descriptionView = (TextView) v.findViewById(R.id.message_description);
        }
    }

}
