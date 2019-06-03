package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import com.grw.mobi.aorm.UserRoleDaoGen;
import com.grw.mobi.aorm.OrmSession;

public class UserRoleDao extends UserRoleDaoGen {

    public UserRoleDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);

    }

}
