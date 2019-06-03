package com.grw.mobi.trackers;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.grw.mobi.Config;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.models.TrackerFileEvent;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Date;

public class TrackerFile extends Tracker {
    private static final Logger logger = LoggerFactory.getLogger(TrackerFile.class);

    Integer trackingId;
    String trackableType;
    String trackableUuid;
    Integer trackableId;

    private TrackerFile(Context context, OrmSession orm, Config config) {
        super(context, orm, config);
        logger.debug("create tracker file");
    }

    public void setTrackingId(@NonNull Integer id) {
        currentStart = new Date();
        trackingId = id;
        trackableType = null;
        trackableUuid = null;
        trackableId = null;
    }

    public void setTrackable(@Nullable OrmModel model) {
        if (model != null) {
            trackableType = model.canonicalModel();
            trackableUuid = model.uuid;
            trackableId = model.mid;
        } else {
            trackableType = null;
            trackableUuid = null;
            trackableId = null;
        }
    }

    public void save(HitFileEvent ob) {
        if (ob.trackingId == null) {
            ob.trackingId = trackingId;
        }
        if (ob.start == null) {
            ob.start = currentStart;
        }
        if (ob.trackableType == null) {
            ob.trackableType = trackableType;
            ob.trackableUuid = trackableUuid;
            ob.trackableId = trackableId;
        }
        if (! ob.toSave()) {
            logger.debug("no save page {} duration {}", ob.page, ob.duration);
            return;
        }
        TrackerFileEvent ev = new TrackerFileEvent(true);
        ev.setSession(orm);
        ev.mobile_device_id = deviceId;
        ev.user_role_id = currentUaId;
        ev.trackable_type = ob.trackableType;
        ev.trackable_uuid = ob.trackableUuid;
        ev.trackable_id = ob.trackableId;
        ev.tracking_id = ob.trackingId;
        ev.beginning = ob.beginning;
        ev.page = ob.page;
        ev.duration = ob.duration;
        ev.created_at = ob.start;
        ev.saveWithTimestamps();
        logger.debug("save {} {} {} {} {} {}", ev.tracking_id, ev.trackable_type, ev.trackable_id, ev.page, ev.beginning, ev.duration);
    }

    private static TrackerFile sTrackerFile;

    public static TrackerFile getInstance(Context context, OrmSession orm, Config config) {
        if (sTrackerFile == null) {
            synchronized (TrackerFile.class) {
                if (sTrackerFile == null) {
                    sTrackerFile = new TrackerFile(context, orm, config);
                }
            }
        }
        return sTrackerFile;
    }

}
