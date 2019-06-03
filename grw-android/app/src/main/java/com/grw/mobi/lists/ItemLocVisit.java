package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.grw.mobi.R;
import com.grw.mobi.models.GeneralComment;
import com.grw.mobi.models.LocationSummary;
import com.grw.mobi.models.LocationVisit;
import com.grw.mobi.util.DateUtils;
import com.grw.mobi.util.Utils;

public class ItemLocVisit extends ARItem {
    LocationVisit locationVisit;
    LocationSummary summary;
    GeneralComment comment;
    OnLocVisitSetListener listener;
    int position;

    public interface OnLocVisitSetListener {
        void onLocVisitSet(String summaryUuid, String locVisitUuid, int position);
    }

    public ItemLocVisit(Context context, LocationVisit locationVisit, OnLocVisitSetListener listener, int position) {
        super(context, CATEGORY_LOC_VISIT);
        this.locationVisit = locationVisit;
        this.listener = listener;
        this.position = position;
        this.summary = locationVisit.summary();
        this.comment = locationVisit.firstComment();
    }

    @Override
    public RecyclerView.ViewHolder createViewHolder(LayoutInflater inflater, ViewGroup parent) {
        View v = inflater.inflate(R.layout.loc_item, parent, false);
        return new DeptViewHolder(v);
    }

    @Override
    public void bindView(RecyclerView.ViewHolder viewHolder) {
        DeptViewHolder h = (DeptViewHolder) viewHolder;

        h.locTime.setText(DateUtils.sHourMinutes.format(locationVisit.start_at));

        if (locationVisit.is_work) {
            if (locationVisit.hasDuration()) {
                h.locDuration.setText(DateUtils.minutesToHM(locationVisit.seconds / 60));
            } else {
                h.locDuration.setText("");
            }
        } else {
            h.locDuration.setText(R.string.loc_history_only_km);
        }

        // stary komunikat
        h.locWarning.setVisibility(View.GONE);

        if (Utils.isBlank(summary.address)) {
            h.locDetails.setText(R.string.loc_history_no_address_short);
        } else {
            h.locDetails.setText(summary.address);
        }

        if (comment != null && comment.comments != null) {
            h.locComments.setVisibility(View.VISIBLE);
            h.locComments.setText(comment.comments);
        } else {
            h.locComments.setVisibility(View.GONE);
        }

        h.itemView.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (listener != null) {
            listener.onLocVisitSet(summary.uuid, locationVisit.uuid, position);
        }
    }

    public static class DeptViewHolder extends RecyclerView.ViewHolder {
        TextView locTime;
        TextView locDuration;
        TextView locDetails;
        TextView locComments;
        TextView locWarning;

        public DeptViewHolder(View v) {
            super(v);
            locTime = (TextView) v.findViewById(R.id.location_time);
            locDuration = (TextView) v.findViewById(R.id.location_duration);
            locDetails = (TextView) v.findViewById(R.id.location_details);
            locComments = (TextView) v.findViewById(R.id.location_comments);
            locWarning = (TextView) v.findViewById(R.id.location_warning);
        }
    }

}
