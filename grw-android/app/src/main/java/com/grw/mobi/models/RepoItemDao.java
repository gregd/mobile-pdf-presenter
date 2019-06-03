package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.RepoItemDaoGen;
import com.grw.mobi.aorm.OrmSession;

public class RepoItemDao extends RepoItemDaoGen {

    public RepoItemDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);

    }

}
