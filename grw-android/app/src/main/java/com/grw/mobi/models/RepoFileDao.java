package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;

import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.aorm.QueryBuilder;
import com.grw.mobi.aorm.RepoFileDaoGen;

import java.util.ArrayList;

public class RepoFileDao extends RepoFileDaoGen {

    enum SortBy {
        Path,
        Size
    }

    public RepoFileDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

    @NonNull
    public QueryBuilder<RepoFile> withName(@NonNull String name) {
        QueryBuilder<RepoFile> q = query();
        q.where("repo_files.repo_name = " + e(name));
        return q;
    }

    @NonNull
    public QueryBuilder<RepoFile> getWithHash(@NonNull String name, @NonNull String hash) {
        QueryBuilder<RepoFile> q = withName(name);
        q.where("repo_files.hash = " + e(hash));
        return q;
    }

    @NonNull
    public QueryBuilder<RepoFile> toDownload(@NonNull String name, @NonNull SortBy sortBy) {
        QueryBuilder<RepoFile> q = withName(name);
        q.where("repo_files.size > 0 AND repo_files.state = " + e(RepoFile.STATE_NEW));
        switch (sortBy) {
            case Path:
                q.order("repo_files.local_path ASC");
                break;
            case Size:
                q.order("repo_files.size ASC");
                break;
        }
        return q;
    }

    @NonNull
    public QueryBuilder<RepoFile> withoutLink(@NonNull String name) {
        QueryBuilder<RepoFile> q = withName(name);
        q.where("repo_item_id IS NULL");
        return q;
    }

    @NonNull
    public ArrayList<String> linkedLocalPaths(@NonNull String name) {
        QueryBuilder<RepoFile> q = withName(name);
        q.where("repo_item_id IS NOT NULL");
        q.selectField("local_path");
        return pickStringColumn(q.selectQuery(), "local_path");
    }

    public void resetRepoPathsForNew() {
        session.mSQLite.execSQL("UPDATE repo_files SET repo_path = NULL WHERE size > 0 AND state = " + e(RepoFile.STATE_NEW));
    }

    public void deleteUnneededNew() {
        session.mSQLite.execSQL("DELETE FROM repo_files WHERE repo_path IS NULL AND size > 0 AND state = " + e(RepoFile.STATE_NEW));
    }

    public void resetLinks() {
        session.mSQLite.execSQL("UPDATE repo_files SET repo_item_id = NULL");
    }

}
