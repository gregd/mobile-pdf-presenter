package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.aorm.QueryBuilder;
import com.grw.mobi.aorm.TrackerFileStateDaoGen;
import com.grw.mobi.aorm.OrmSession;

import java.util.List;

public class TrackerFileStateDao extends TrackerFileStateDaoGen {

    public TrackerFileStateDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

    @NonNull
    public QueryBuilder<TrackerFileState> withTrackable(@NonNull Integer trackingId, @NonNull OrmModel trackable) {
        QueryBuilder<TrackerFileState> q = query();
        q.where("deleted_at IS NULL");
        q.where("tracking_id = " + trackingId);
        q.where("trackable_type = " + e(trackable.canonicalModel()));
        q.where("trackable_uuid = " + e(trackable.uuid));
        return q;
    }

    @Nullable
    public TrackerFileState findFor(@NonNull Integer trackingId, @NonNull OrmModel trackable) {
        List<TrackerFileState> res = withTrackable(trackingId, trackable).execute();
        return res.size() > 0 ? res.get(0) : null;
    }

    public TrackerFileState findOrCreate(@NonNull Integer trackingId, @NonNull OrmModel trackable) {
        TrackerFileState res = findFor(trackingId, trackable);
        if (res != null) return res;

        res = new TrackerFileState(trackingId, trackable);
        res.setSession(session);
        return res;
    }

}
