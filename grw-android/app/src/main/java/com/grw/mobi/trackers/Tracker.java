package com.grw.mobi.trackers;

import android.content.Context;
import android.support.annotation.NonNull;

import com.grw.mobi.Config;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.util.NetUtils;

import java.util.Date;

public abstract class Tracker {
    protected Context context;
    protected OrmSession orm;
    protected Config config;
    protected Integer deviceId;
    protected Integer appVersion;
    protected Integer currentUaId;

    protected Date currentStart;

    protected Tracker(Context context, OrmSession orm, Config config) {
        this.context = context;
        this.orm = orm;
        this.config = config;
        this.appVersion = NetUtils.getPackageInfo(context).versionCode;
        int i = config.getMobileDeviceId();
        if (i != Config.NO_INT_VAL) {
            this.deviceId = i;
        }
    }

    public void setUaId(@NonNull Integer uaId, @NonNull Integer deviceId) {
        this.currentUaId = (uaId != Config.NO_INT_VAL) ? uaId : null;
        this.deviceId = (deviceId != Config.NO_INT_VAL) ? deviceId : null;
    }

}
