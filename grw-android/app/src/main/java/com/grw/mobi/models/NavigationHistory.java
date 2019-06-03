package com.grw.mobi.models;

import android.support.annotation.NonNull;

import com.grw.mobi.Session;
import com.grw.mobi.aorm.NavigationHistoryGen;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.presenters.RepoFilePresenter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NavigationHistory extends NavigationHistoryGen {
    private static final Logger logger = LoggerFactory.getLogger(NavigationHistory.class);
    public static final String CATEGORY_MODEL   = "model";
    public static final String CATEGORY_FILE    = "file";
    public static final String ACTION_NAV       = "navigation";
    public static final String ACTION_HISTORY   = "history";

    private static int AddedCount = 0;

    public NavigationHistory() {}

    public NavigationHistory(@NonNull OrmModel model, @NonNull String action) {
        initLocal();
        this.category = CATEGORY_MODEL;
        this.action = action;
        this.object_type = model.canonicalModel();
        this.object_uuid = model.uuid;
        this.object_id = model.mid;
    }

    public NavigationHistory(@NonNull RepoFilePresenter pres, @NonNull String action) {
        initLocal();
        this.category = CATEGORY_FILE;
        this.action = action;
        this.extra1 = pres.getRepoName();
        this.extra2 = pres.getRelPath();
        this.description = pres.getTitle();
    }

    public static void remember(@NonNull OrmSession orm, @NonNull Session session, @NonNull RepoFilePresenter pres) {
        NavigationHistory recent = orm.navigationHistoryDao.recent(session.user().mid, pres);
        if (recent != null) {
            // just update the timestamp
            recent.saveWithTimestamps();
            return;
        }

        NavigationHistory n = new NavigationHistory(pres, ACTION_NAV);
        n.user_id = session.user().mid;
        n.setSession(orm);
        n.saveWithTimestamps();
        maintenance(orm);
    }

    public static void remember(@NonNull OrmSession orm, @NonNull Session session, @NonNull OrmModel model) {
        NavigationHistory recent = orm.navigationHistoryDao.recent(session.user().mid, model);
        if (recent != null) {
            // just update the timestamp
            recent.saveWithTimestamps();
            return;
        }

        NavigationHistory n = new NavigationHistory(model, ACTION_NAV);
        n.user_id = session.user().mid;
        n.setSession(orm);
        n.saveWithTimestamps();
        maintenance(orm);
    }

    private static void maintenance(@NonNull OrmSession orm) {
        AddedCount += 1;
        if (AddedCount < 10) return;
        AddedCount = 0;

        // TODO remove old
    }

}
