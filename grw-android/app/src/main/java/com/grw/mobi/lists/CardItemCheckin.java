package com.grw.mobi.lists;

import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.grw.mobi.R;
import com.grw.mobi.Session;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.models.LocationVisit;
import com.grw.mobi.services.LocationReportService;
import com.grw.mobi.ui.CheckinActivity;
import com.grw.mobi.ui.LocationsActivity;
import com.grw.mobi.util.DateUtils;

import java.util.ArrayList;
import java.util.Date;

public class CardItemCheckin extends CardItem {

    @NonNull Date day = DateUtils.today();
    @Nullable LocationReportService visitService;
    @Nullable LocationReportService.LocationSummaryReport summaryReport;
    @Nullable LocationVisit locationVisit;

    public CardItemCheckin(Context context, OrmSession orm, Session session) {
        super(context, orm, session, CARD_CHECKIN);
        loadModels();
    }

    @Override
    public void loadModels() {
        visitService = new LocationReportService(orm, session);
        summaryReport = visitService.locationSummaryReport(day);
        ArrayList<LocationVisit> locationVisits = orm.locationVisitDao.latestFor(session.assignment().mid, day, 1);
        if (locationVisits.size() == 1) {
            locationVisit = locationVisits.get(0);
        } else {
            locationVisit = null;
        }
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(ViewGroup parent) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.start_card_checkin, parent, false);
        return new CheckinViewHolder(view);
    }

    @Override
    public void bindView(final Context context, RecyclerView.ViewHolder viewHolder) {
        CheckinViewHolder h = (CheckinViewHolder) viewHolder;

        if (summaryReport != null) {
            h.db_checkin_visits_time.setText(
                    Html.fromHtml(context.getString(R.string.db_checkin_visits_time) +
                            " <b>" + DateUtils.secondsToHM(summaryReport.workSeconds) + "</b>"));

            if (summaryReport.reportedAvgSeconds != null) {
                h.db_checkin_avg_per_visit.setText(
                        Html.fromHtml(context.getString(R.string.db_checkin_avg_per_visit) +
                                " <b>" + DateUtils.secondsToHM(summaryReport.reportedAvgSeconds) + "</b>"));

            } else {
                if (summaryReport.reportedUnlockedCount == 0) {
                    h.db_checkin_avg_per_visit.setText(R.string.db_checkin_no_visits);
                } else {
                    h.db_checkin_avg_per_visit.setText(R.string.db_checkin_no_avg);
                }
            }

            h.db_checkin_checkin.setText(R.string.db_checkin_checkin);
        }
        h.db_checkin_checkin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(context, CheckinActivity.class);
                context.startActivity(intent);
            }
        });
        h.db_checkin_locations.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(context, LocationsActivity.class);
                context.startActivity(intent);
            }
        });
    }

    public static class CheckinViewHolder extends RecyclerView.ViewHolder {
        CardView db_card_checkin;
        TextView db_checkin_visits_time;
        TextView db_checkin_avg_per_visit;
        Button db_checkin_checkin;
        Button db_checkin_locations;

        public CheckinViewHolder(View v) {
            super(v);
            db_card_checkin = (CardView) v.findViewById(R.id.db_card_checkin);
            db_checkin_visits_time = (TextView) v.findViewById(R.id.db_checkin_visits_time);
            db_checkin_avg_per_visit = (TextView) v.findViewById(R.id.db_checkin_avg_per_visit);
            db_checkin_checkin = (Button) v.findViewById(R.id.db_checkin_checkin);
            db_checkin_locations = (Button) v.findViewById(R.id.db_checkin_locations);
        }
    }

}
