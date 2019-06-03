package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.AppRoleDaoGen;
import com.grw.mobi.aorm.OrmSession;

public class AppRoleDao extends AppRoleDaoGen {

    public AppRoleDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);

    }

}
