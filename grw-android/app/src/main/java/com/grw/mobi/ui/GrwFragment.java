package com.grw.mobi.ui;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;

import com.grw.mobi.Config;
import com.grw.mobi.Session;
import com.grw.mobi.aorm.OrmDatabase;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.events.DataEvent;
import com.grw.mobi.trackers.TrackerApp;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public abstract class GrwFragment extends Fragment {
    protected static final int FIRST_PAGE = 8;
    protected static final int MAX_LOAD = 1000;

    protected boolean mReloadData = false;

    protected Context context;
    protected Session session;
    protected OrmSession orm;
    protected Config config;

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        this.context = context;
        config = Config.getInstance(context);
        session = Session.getInstance(context);
        orm = OrmDatabase.getInstance().defaultSession();
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEvent(DataEvent event) {
        if (isResumed()) {
            if (isRemoving()) return;
            refreshUI(true);
        } else {
            mReloadData = true;
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (! EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this);
        }
        if (mReloadData) {
            mReloadData = false;
            refreshUI(true);
        }
    }

    @Override
    public void onDestroy() {
        EventBus.getDefault().unregister(this);
        super.onDestroy();
    }

    public void refreshUI(boolean restorePosition) {}

    @Nullable
    public TrackerApp getActivityTracker() {
        FragmentActivity activity = getActivity();
        if (activity == null || ! (activity instanceof GrwActivity)) return null;
        return ((GrwActivity) activity).getTracker();
    }

}
