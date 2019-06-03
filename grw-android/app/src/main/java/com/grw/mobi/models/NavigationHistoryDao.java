package com.grw.mobi.models;

import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.util.Pair;

import com.grw.mobi.aorm.NavigationHistoryDaoGen;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.aorm.QueryBuilder;
import com.grw.mobi.presenters.RepoFilePresenter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class NavigationHistoryDao extends NavigationHistoryDaoGen {
    private static final Logger logger = LoggerFactory.getLogger(NavigationHistoryDao.class);

    public NavigationHistoryDao(OrmSession session, SQLiteDatabase db) {
        super(session, db);
    }

    @Nullable
    public NavigationHistory recent(@NonNull Integer userId, @NonNull RepoFilePresenter pres) {
        QueryBuilder<NavigationHistory> q = query();
        q.where("category = " + e(NavigationHistory.CATEGORY_FILE));
        q.where("action = " + e(NavigationHistory.ACTION_NAV));
        q.where("user_id = " + userId);
        q.where("extra1 = " + e(pres.getRepoName()));
        q.where("extra2 = " + e(pres.getRelPath()));
        q.limit(1);
        ArrayList<NavigationHistory> res = q.execute();
        return res.size() > 0 ? res.get(0) : null;
    }

    @Nullable
    public NavigationHistory recent(@NonNull Integer userId, @NonNull OrmModel model) {
        QueryBuilder<NavigationHistory> q = query();
        q.where("category = " + e(NavigationHistory.CATEGORY_MODEL));
        q.where("action = " + e(NavigationHistory.ACTION_NAV));
        q.where("user_id = " + userId);
        q.where("object_type = " + e(model.canonicalModel()));
        if (model.uuid != null) {
            q.where("object_uuid = " + e(model.uuid));
        }
        if (model.mid > 0) {
            q.where("object_id = " + model.mid);
        }
        q.order("updated_at DESC");
        q.limit(1);
        ArrayList<NavigationHistory> res = q.execute();
        return res.size() > 0 ? res.get(0) : null;
    }

    @NonNull
    public List<OrmModel> recentModels(@NonNull Integer maxCount) {
        List<OrmModel> result = new ArrayList<>();
        QueryBuilder<NavigationHistory> q = query();
        q.where("category = " + e(NavigationHistory.CATEGORY_MODEL));
        q.where("action = " + e(NavigationHistory.ACTION_NAV));
        q.order("updated_at DESC");
        q.limit(maxCount);
        ArrayList<NavigationHistory> arr = q.execute();
        for (NavigationHistory n : arr) {
            OrmModel m = session.findByNameUuidOrId(n.object_type, n.object_uuid, n.object_id);
            if (m != null) {
                result.add(m);
            }
        }
        return result;
    }

    @NonNull
    public List<NavigationHistory> recentFiles(@NonNull Integer maxCount) {
        QueryBuilder<NavigationHistory> q = query();
        q.where("category = " + e(NavigationHistory.CATEGORY_FILE));
        q.where("action = " + e(NavigationHistory.ACTION_NAV));
        q.order("updated_at DESC");
        q.limit(maxCount);
        return q.execute();
    }

    public void historyLoaded(@NonNull ArrayList<Pair<String, String>> list) {
        for (Pair<String, String> p : list) {
            OrmModel m = session.findByNameUuidOrId(p.first, p.second, null);
            if (m == null) {
                logger.warn("historyLoaded model not found {} {}", p.first, p.second);
                continue;
            }
            if (historyFor(p.first, p.second) != null) {
                logger.warn("historyLoaded existing {} {}", p.first, p.second);
                continue;
            }
            NavigationHistory h = new NavigationHistory(m, NavigationHistory.ACTION_HISTORY);
            h.setSession(session);
            h.saveWithTimestamps();
        }
    }

    @Nullable
    public NavigationHistory historyFor(@NonNull OrmModel model) {
        return historyFor(model.canonicalModel(), model.uuid);
    }

    @Nullable
    public NavigationHistory historyFor(@NonNull String klass, @NonNull String uuid) {
        QueryBuilder<NavigationHistory> q = query();
        q.where("category = " + e(NavigationHistory.CATEGORY_MODEL));
        q.where("action = " + e(NavigationHistory.ACTION_HISTORY));
        q.where("object_type = " + e(klass));
        q.where("object_uuid = " + e(uuid));
        ArrayList<NavigationHistory> res = q.execute();
        return res.size() > 0 ? res.get(0) : null;
    }

}
