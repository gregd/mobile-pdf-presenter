package com.grw.mobi.lists;

import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.grw.mobi.Config;
import com.grw.mobi.R;
import com.grw.mobi.Session;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.models.NavigationHistory;
import com.grw.mobi.models.PresentationClient;
import com.grw.mobi.ui.RepoBrowserActivity;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class CardItemRecentPresentations extends CardItem {
    private static final Logger logger = LoggerFactory.getLogger(CardItemRecentPresentations.class);

    private static final int MAX_FILES = 5;

    Config config;

    ArrayList<ARItem> items = new ArrayList<>();
    String recipientName;

    public CardItemRecentPresentations(Context context, OrmSession orm, Session session, Config config) {
        super(context, orm, session, CARD_RECENT_PRESENTATIONS);
        this.config = config;
        loadModels();
    }

    @Override
    public void loadModels() {
        List<NavigationHistory> recent = orm.navigationHistoryDao.recentFiles(MAX_FILES);
        items.clear();
        for (NavigationHistory nh : recent) {
            items.add(new ItemRepoPres(context, config, orm, nh));
        }

        OrmModel model = PresentationClient.get(config);
        if (model == null) {
            recipientName = null;
            return;
        }

//        if (model.canonicalModel().equals("Person")) {
//            PersonPresenter presenter = new PersonPresenter(session.assignment(), (Person) model);
//            recipientName = presenter.specAbbrFullName();
//
//        } else if (model.canonicalModel().equals("Institution")) {
//            InstPresenter presenter = new InstPresenter(session.assignment(), (Institution) model);
//            recipientName = presenter.fullName();
//
//        } else {
//            logger.warn("model unknown {}", model.canonicalModel());
//            recipientName = null;
//        }
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(ViewGroup parent) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.start_card_recent_presentations, parent, false);
        return new RecentPresentationsViewHolder(view);
    }

    @Override
    public void bindView(final Context context, RecyclerView.ViewHolder viewHolder) {
        RecentPresentationsViewHolder h = (RecentPresentationsViewHolder) viewHolder;

        h.db_recent_presentations_context.setVisibility(View.GONE);
//        if (recipientName != null) {
//            h.db_recent_presentations_context.setText(
//                    Html.fromHtml(
//                            context.getString(R.string.db_recent_presentations_context) + "<b>" + recipientName + "</b>"));
//        } else {
//            h.db_recent_presentations_context.setText(
//                    R.string.db_recent_presentations_no_context);
//        }

        ARItemAdapter adapter = new ARItemAdapter(context, session, h.db_recent_presentations_list, items,
                ARItemAdapter.LINEAR);
        h.db_recent_presentations_list.setAdapter(adapter);

        h.db_recent_presentations_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(context, RepoBrowserActivity.class);
                context.startActivity(intent);
            }
        });
    }

    public static class RecentPresentationsViewHolder extends RecyclerView.ViewHolder {
        TextView db_recent_presentations_context;
        RecyclerView db_recent_presentations_list;
        Button db_recent_presentations_btn;

        public RecentPresentationsViewHolder(View v) {
            super(v);
            db_recent_presentations_context = (TextView) v.findViewById(R.id.db_recent_presentations_context);
            db_recent_presentations_list = (RecyclerView) v.findViewById(R.id.db_recent_presentations_list);
            db_recent_presentations_btn = (Button) v.findViewById(R.id.db_recent_presentations_btn);
        }
    }

}
