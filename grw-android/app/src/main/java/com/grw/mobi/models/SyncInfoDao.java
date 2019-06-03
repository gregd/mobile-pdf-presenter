package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.SyncInfoDaoGen;
import com.grw.mobi.aorm.OrmSession;

import java.util.ArrayList;

public class SyncInfoDao extends SyncInfoDaoGen {
    public static final int sId = 1;

    public SyncInfoDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

    public boolean isInitialized() {
        return tableExists() && countWhere("_id = " + sId) == 1;
    }

    public SyncInfo getInstance() {
        ArrayList<SyncInfo> res = selectWhere("_id = " + sId);
        if (res.size() != 1) throw new RuntimeException("Cannot find SyncInfo record");
        return  res.get(0);
    }

    public long lastLoadAgo() {
        SyncInfo si = getInstance();
        return si.last_load_at == null ? Long.MAX_VALUE : System.currentTimeMillis() - si.last_load_at.getTime();
    }

    public void setDataOwnerId(int dataOwnerId, int dataAssignmentId, String company) {
        SyncInfo si = getInstance();
        si.data_owner_id = dataOwnerId;
        si.data_assignment_id = dataAssignmentId;
        si.data_company = company;
        si.save();
    }

    public static void initializeDefault(SQLiteDatabase db) {
        db.execSQL("INSERT INTO sync_info (_id, sync_started_at, last_load_at, last_upload_at, data_owner_id, data_assignment_id, data_company) " +
                "VALUES (" + sId + ", NULL, NULL, NULL, -1, -1, NULL)");
    }

}
