package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.grw.mobi.aorm.QueryBuilder;
import com.grw.mobi.aorm.RepoFileDaoGen;
import com.grw.mobi.aorm.RepoItemDaoGen;
import com.grw.mobi.aorm.RepoRevisionDaoGen;
import com.grw.mobi.aorm.OrmSession;

import java.util.ArrayList;

public class RepoRevisionDao extends RepoRevisionDaoGen {

    public RepoRevisionDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

    @NonNull
    public QueryBuilder<RepoRevision> withName(@NonNull String name) {
        QueryBuilder<RepoRevision> q = query();
        q.where("repo_name = " + e(name));
        return q;
    }

    @Nullable
    public RepoRevision getLatest(@NonNull String name) {
        QueryBuilder<RepoRevision> q = withName(name);
        q.order("modified_at DESC");
        q.limit(1);
        ArrayList<RepoRevision> res = q.execute();
        return res.size() > 0 ? res.get(0) : null;
    }

    @Nullable
    public RepoRevision getCurrent(@NonNull String name) {
        QueryBuilder<RepoRevision> q = withName(name);
        q.where("state = " + e(RepoRevision.STATE_CURRENT));
        q.limit(1);
        ArrayList<RepoRevision> res = q.execute();
        return res.size() > 0 ? res.get(0) : null;
    }

    @Nullable
    public RepoRevision getWithHash(@NonNull String name, @NonNull String hash) {
        QueryBuilder<RepoRevision> q = withName(name);
        q.where("hash = " + e(hash));
        q.limit(1);
        ArrayList<RepoRevision> res = q.execute();
        return res.size() > 0 ? res.get(0) : null;
    }

    public void resetRepoTables() {
        RepoRevisionDaoGen.createTable(session.mSQLite, true);
        RepoItemDaoGen.createTable(session.mSQLite, true);
        RepoFileDaoGen.createTable(session.mSQLite, true);
    }

}
