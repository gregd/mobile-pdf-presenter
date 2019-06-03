package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.ViewGroup;

import com.grw.mobi.Session;
import com.grw.mobi.aorm.OrmSession;

public abstract class CardItem {
    public static final int CARD_ACTIVITY = 1;
    public static final int CARD_CHECKIN = 2;
    public static final int CARD_CITIES_VISITS = 3;
    public static final int CARD_RECENT_PERSONS = 4;
    public static final int CARD_RECENT_PRESENTATIONS = 5;

    protected Context context;
    protected OrmSession orm;
    protected Session session;
    protected int cardType;

    public CardItem(Context context, OrmSession orm, Session session, int cardType) {
        this.context = context;
        this.orm = orm;
        this.session = session;
        this.cardType = cardType;
    }

    public int getViewType() {
        return cardType;
    }

    abstract public void loadModels();

    abstract public RecyclerView.ViewHolder createViewHolder(ViewGroup parent);

    abstract public void bindView(final Context context, RecyclerView.ViewHolder viewHolder);

}
