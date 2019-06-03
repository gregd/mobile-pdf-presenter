package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.grw.mobi.Config;
import com.grw.mobi.R;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.models.NavigationHistory;
import com.grw.mobi.presenters.RepoFilePresenter;
import com.grw.mobi.services.RepoService;
import com.grw.mobi.util.NavUtils;

public class ItemRepoPres extends ARItem {
    Config config;
    OrmSession orm;
    NavigationHistory navigationHistory;

    public ItemRepoPres(Context context, Config config, OrmSession orm, NavigationHistory navigationHistory) {
        super(context, CATEGORY_REPO_PRES);
        this.config = config;
        this.orm = orm;
        this.navigationHistory = navigationHistory;
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent) {
        View v = inflater.inflate(R.layout.repo_pres_item, parent, false);
        return new LoadRepoPresViewHolder(v);
    }

    @Override
    public void bindView(RecyclerView.ViewHolder viewHolder) {
        LoadRepoPresViewHolder h = (LoadRepoPresViewHolder) viewHolder;
        h.title.setText(navigationHistory.description);
        h.itemView.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        RepoService service = new RepoService(context, config, orm, navigationHistory.extra1);
        RepoFilePresenter pres = service.getFile(navigationHistory.extra2);
        if (pres != null) {
            NavUtils.openRepoFile(context, pres);
        } else {
            Toast.makeText(context, R.string.browser_no_file, Toast.LENGTH_LONG).show();
        }
    }

    public static class LoadRepoPresViewHolder extends RecyclerView.ViewHolder {
        TextView title;

        public LoadRepoPresViewHolder(View v) {
            super(v);
            title = (TextView) v.findViewById(R.id.repo_pres_title);
        }
    }


}
