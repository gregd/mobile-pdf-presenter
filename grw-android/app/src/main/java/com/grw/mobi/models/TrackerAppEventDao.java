package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;

import com.grw.mobi.aorm.OrmIdMapping;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.aorm.TrackerAppEventDaoGen;

public class TrackerAppEventDao extends TrackerAppEventDaoGen {

    public TrackerAppEventDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

    @Override
    public boolean handleSync(OrmIdMapping mapping) {
        // don't keep synced records
        deleteWhere("_id = " + mapping.local_id);
        return false;
    }

    public void addMissingData(@NonNull Integer deviceId, @NonNull Integer uaId) {
        mSQLite.execSQL("UPDATE " + table + " SET " +
                "mobile_device_id = " + deviceId + ", " +
                "user_role_id = " + uaId + " " +
                "WHERE mobile_device_id IS NULL OR user_role_id IS NULL");
    }

}
