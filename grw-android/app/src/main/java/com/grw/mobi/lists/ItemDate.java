package com.grw.mobi.lists;

import android.content.Context;
import android.graphics.Typeface;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.grw.mobi.R;
import com.grw.mobi.util.DateUtils;

import java.util.Date;

public class ItemDate extends ARItem {
    public Date mDate;

    public ItemDate(Context context, Date dateSep) {
        super(context, CATEGORY_DATE);
        mDate = dateSep;
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent) {
        View v = inflater.inflate(R.layout.date_item, parent, false);
        return new DateViewHolder(v);
    }

    @Override
    public void bindView(RecyclerView.ViewHolder viewHolder) {
        DateViewHolder h = (DateViewHolder) viewHolder;

        h.dateView.setText(DateUtils.dateToLabel(context, mDate));
        if (mDate.getTime() < DateUtils.today().getTime()) {
            h.dateView.setTypeface(Typeface.DEFAULT, Typeface.ITALIC);
        } else {
            h.dateView.setTypeface(Typeface.DEFAULT, Typeface.NORMAL);
        }
    }

    public static class DateViewHolder extends RecyclerView.ViewHolder {
        TextView dateView;

        public DateViewHolder(View v) {
            super(v);
            dateView = (TextView) v.findViewById(R.id.date_item_name);
        }
    }

}

