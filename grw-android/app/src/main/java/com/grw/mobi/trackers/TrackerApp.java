package com.grw.mobi.trackers;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.grw.mobi.Config;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.models.TrackerAppEvent;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Date;

public class TrackerApp extends Tracker {
    private static final Logger logger = LoggerFactory.getLogger(TrackerApp.class);

    String currentScreen;
    String currentLabel;
    Integer currentPersonId;
    Integer currentInstId;

    private TrackerApp(Context context, OrmSession orm, Config config) {
        super(context, orm, config);
        logger.debug("create tracker app");
    }

    public void addMissingData() {
        if (currentUaId == null || deviceId == null) return;
        orm.trackerAppEventDao.addMissingData(deviceId, currentUaId);
    }

    public void setScreen(@NonNull String screen) {
        currentStart = new Date();
        currentScreen = screen;
        currentPersonId = null;
        currentInstId = null;
        currentLabel = null;
    }

    public void setLabel(@Nullable String label) {
        currentLabel = label;
    }

    public void setPersonId(@Nullable Integer personId) {
        currentPersonId = personId;
    }

    public void setInstId(@Nullable Integer instId) {
        currentInstId = instId;
    }

    public void save(HitAppEvent ob) {
        if (ob.screen == null) {
            ob.screen = currentScreen;
        }
        if (ob.start == null) {
            ob.start = currentStart;
        }
        if (ob.label == null) {
            ob.label = currentLabel;
        }
        if (ob.personId == null) {
            ob.personId = currentPersonId;
        }
        if (ob.instId == null) {
            ob.instId = currentInstId;
        }
        TrackerAppEvent ev = new TrackerAppEvent(true);
        ev.setSession(orm);
        ev.app_version = appVersion;
        ev.mobile_device_id = deviceId;
        ev.user_role_id = currentUaId;
        ev.screen = ob.screen;
        ev.category = ob.category;
        ev.action = ob.action;
        ev.label = ob.label;
        ev.value = ob.value;
        ev.person_id = ob.personId;
        ev.institution_id = ob.instId;
        ev.created_at = ob.start;
        ev.saveWithTimestamps();
        //logger.debug("save {} {} {} {} {}", ev.screen, ev.category, ev.action, ev.label, ev.value);
    }

    private static TrackerApp sTrackerApp;

    public static TrackerApp getInstance(Context context, OrmSession orm, Config config) {
        if (sTrackerApp == null) {
            synchronized (TrackerApp.class) {
                if (sTrackerApp == null) {
                    sTrackerApp = new TrackerApp(context, orm, config);
                }
            }
        }
        return sTrackerApp;
    }

}
