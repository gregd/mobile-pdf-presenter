package com.grw.mobi.services;

import android.database.DatabaseUtils;
import android.text.TextUtils;

import java.util.ArrayList;

public class StatelessService {

    public static String ids(ArrayList<Integer> list) {
        if (list.size() == 0) {
            return "NULL";
        }
        return TextUtils.join(",", list);
    }

    public static void e(StringBuilder sb, String sqlString) {
        DatabaseUtils.appendEscapedSQLString(sb, sqlString);
    }

    public static String e(String value) {
        return DatabaseUtils.sqlEscapeString(value);
    }

}
