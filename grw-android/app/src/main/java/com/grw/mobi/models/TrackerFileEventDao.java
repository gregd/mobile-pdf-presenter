package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.TrackerFileEventDaoGen;
import com.grw.mobi.aorm.OrmSession;

public class TrackerFileEventDao extends TrackerFileEventDaoGen {

    public TrackerFileEventDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

    public void deleteFromId(int id) {
        deleteWhere("_id > " + id);
    }

}
