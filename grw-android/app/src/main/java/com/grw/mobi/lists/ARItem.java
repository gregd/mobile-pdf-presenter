package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

public abstract class ARItem implements View.OnClickListener {
    public static final int CATEGORY_DATE           = 1;
    public static final int CATEGORY_INST           = 2;
    public static final int CATEGORY_INST_MAP       = 3;
    public static final int CATEGORY_INST_WP        = 4;
    public static final int CATEGORY_PERSON         = 5;
    public static final int CATEGORY_PERSON_MAP     = 6;
    public static final int CATEGORY_VISIT          = 7;
    public static final int CATEGORY_VISIT_DETAILS  = 8;
    public static final int CATEGORY_ACTIVITY       = 9;
    public static final int CATEGORY_ACTIVITY_NEW   = 10;
    public static final int CATEGORY_LOC_VISIT      = 11;
    public static final int CATEGORY_MESSAGE        = 12;
    public static final int CATEGORY_REPO_FILE      = 13;
    public static final int CATEGORY_LOAD_NEXT      = 14;
    public static final int CATEGORY_LOAD_OLD       = 15;
    public static final int CATEGORY_PERSON_WP      = 16;
    public static final int CATEGORY_REPO_PRES      = 17;
    public static final int CATEGORY_PERSON_SELECT  = 18;
    public static final int CATEGORY_INST_CHOICE    = 19;
    public static final int CATEGORY_PERSON_CHOICE  = 20;
    public static final int CATEGORY_PIC_ATTACHMENT = 21;

    protected Context context;
    protected int mCategory;

    public ARItem(Context context, int category) {
        this.context = context;
        this.mCategory = category;
    }

    public int getViewType() {
        return mCategory;
    }

    abstract public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent);

    abstract public void bindView(RecyclerView.ViewHolder viewHolder);

    @Override
    public void onClick(View v) {}

}
