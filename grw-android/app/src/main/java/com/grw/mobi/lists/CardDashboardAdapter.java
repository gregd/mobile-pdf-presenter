package com.grw.mobi.lists;

import android.content.Context;
import android.graphics.Rect;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

import java.util.HashMap;
import java.util.List;

public class CardDashboardAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    Context context;
    List<CardItem> items;
    HashMap<Integer, CardItem> categoryMap = new HashMap<>();

    public CardDashboardAdapter(Context context, List<CardItem> items) {
        this.context = context;
        this.items = items;

        for (CardItem item : items) {
            if (categoryMap.containsKey(item.getViewType())) continue;
            categoryMap.put(item.getViewType(), item);
        }
    }

    @Override
    public int getItemViewType(int position) {
        return items.get(position).getViewType();
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        CardItem item = categoryMap.get(viewType);
        return item.createViewHolder(parent);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        items.get(position).bindView(context, holder);
    }

    public static class SpacesItemDecoration extends RecyclerView.ItemDecoration {
        private final int mSpace;   // device px

        public SpacesItemDecoration(Context context, int space) {
            this.mSpace = Math.round(context.getResources().getDisplayMetrics().density * space);
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            outRect.left = mSpace;
            outRect.right = mSpace;
            outRect.bottom = mSpace;
            outRect.top = mSpace;
        }
    }
}
