package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.UserMobileOptionDaoGen;
import com.grw.mobi.aorm.OrmSession;

public class UserMobileOptionDao extends UserMobileOptionDaoGen {

    public UserMobileOptionDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);

    }

}
