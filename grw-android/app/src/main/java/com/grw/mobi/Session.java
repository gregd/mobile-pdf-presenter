package com.grw.mobi;

import android.content.Context;

import com.grw.mobi.aorm.OrmDatabase;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.models.User;
import com.grw.mobi.models.UserRole;
import com.grw.mobi.systemservices.SyncScheduler;
import com.grw.mobi.util.DateUtils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Date;

public class Session {
    private static final Logger logger = LoggerFactory.getLogger(Session.class);

    private Context context;
    private Config config;

    private User mUser;
    private UserRole mAssignment;

    private Date mVisitPlanAt;

    public Session(Context context) {
        this.context = context;
        this.config = Config.getInstance(context);
    }

    public void reload() {
        if (config.isLogged()) {
            loadUser();
        } else {
            logger.debug("reload logout");
            mUser = null;
            mAssignment = null;
        }
    }

    public void logout() {
        mUser = null;
        mAssignment = null;
        config.resetLoginData();
        SyncScheduler.stopAlarm(context);
    }

    public boolean isLoaded() {
        return mUser != null && mAssignment != null;
    }

    protected void loadUser() {
        OrmSession orm = OrmDatabase.getInstance().defaultSession();
        mUser       = orm.userDao.find(config.getUserId());
        mAssignment = orm.userRoleDao.find(config.getUserRoleId());

        if (mUser == null || mAssignment == null) {
            mUser = null;
            mAssignment = null;
            logger.debug("no user data {} {}", config.getUserId(), config.getUserRoleId());
            return;
        }
        if (mAssignment.appRole() == null || mUser.mobileOption() == null) {
            mUser = null;
            mAssignment = null;
            logger.warn("no user options");
            return;
        }
        if (mAssignment.user_id != config.getUserId())  {
            config.resetLoginData();
            orm.createTables(true);
            throw new RuntimeException("session cannot load user");
        }
        logger.debug("loadUser {} {}", mUser.mid, mAssignment.mid);
    }

    public User user() {
        return mUser;
    }

    public UserRole assignment() {
        return mAssignment;
    }

    public Date getVisitPlanAt() {
        if (mVisitPlanAt != null && ! DateUtils.isFuture(mVisitPlanAt)) {
            mVisitPlanAt = null;
        }
        if (mVisitPlanAt == null) {
            Date today = DateUtils.getStart(new Date());
            mVisitPlanAt = DateUtils.addDays(today, 21);
            // TODO save the date to the pref ?
        }
        return mVisitPlanAt;
    }

    public void setVisitPlanAt(Date pDay) {
        mVisitPlanAt = pDay;
    }

    private static Session sSession;

    public static Session getInstance(Context context) {
        if (sSession == null) {
            synchronized (Session.class) {
                if (sSession == null) {
                    sSession = new Session(context);
                    sSession.reload();
                }
            }
        }
        return sSession;
    }

}
