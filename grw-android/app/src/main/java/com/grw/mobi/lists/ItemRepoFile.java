package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.grw.mobi.R;
import com.grw.mobi.presenters.RepoFilePresenter;
import com.grw.mobi.util.NavUtils;
import com.squareup.picasso.Picasso;

public class ItemRepoFile extends ARItem {
    RepoFilePresenter pres;

    public ItemRepoFile(Context context, RepoFilePresenter pres) {
        super(context, CATEGORY_REPO_FILE);
        this.pres = pres;
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent) {
        View v = inflater.inflate(R.layout.browser_item_file, parent, false);
        return new RepoFileViewHolder(v);
    }

    @Override
    public void bindView(RecyclerView.ViewHolder viewHolder) {
        RepoFileViewHolder h = (RepoFileViewHolder) viewHolder;

        // When using Picasso, if you use resize() and put one of the dimensions as 0 it will maintain aspect ratio.
        if (pres.cover != null) {
            String url = "file://" + pres.cover.getAbsolutePath();
            Picasso.with(context).
                    load(url).
                    resizeDimen(R.dimen.repo_cover_width, R.dimen.repo_cover_height).
                    centerInside().
                    placeholder(R.drawable.ic_image_broken_64dp).
                    into(h.iv);

        } else {
            h.iv.setImageResource(pres.iconResId);
        }

        h.title.setText(pres.getTitle());

        String d = pres.getDescription(context);
        if (d != null) {
            h.desc.setText(d);
            h.desc.setVisibility(View.VISIBLE);
        } else {
            h.desc.setVisibility(View.GONE);
        }

        if (pres.stateProgress != null) {
            String s = String.format(context.getString(R.string.browser_progress), pres.stateProgress);
            h.progress.setText(s);
            h.progress.setVisibility(View.VISIBLE);
        } else {
            h.progress.setVisibility(View.GONE);
        }

        h.itemView.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        NavUtils.openRepoFile(context, pres);
    }

    public static class RepoFileViewHolder extends RecyclerView.ViewHolder {
        ImageView iv;
        TextView title;
        TextView desc;
        TextView progress;

        public RepoFileViewHolder(View v) {
            super(v);
            iv = (ImageView) v.findViewById(R.id.browser_item_image);
            title = (TextView) v.findViewById(R.id.browser_item_title);
            desc = (TextView) v.findViewById(R.id.browser_item_description);
            progress = (TextView) v.findViewById(R.id.browser_item_progress);
        }
    }

}
