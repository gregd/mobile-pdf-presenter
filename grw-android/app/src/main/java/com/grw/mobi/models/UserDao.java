package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.aorm.UserDaoGen;

public class UserDao extends UserDaoGen {
    public UserDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

}
