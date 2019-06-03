package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.GeneralCommentDaoGen;
import com.grw.mobi.aorm.OrmSession;

public class GeneralCommentDao extends GeneralCommentDaoGen {

    public GeneralCommentDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);

    }

}
