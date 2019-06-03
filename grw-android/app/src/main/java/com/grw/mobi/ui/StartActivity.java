package com.grw.mobi.ui;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.grw.mobi.Config;
import com.grw.mobi.R;
import com.grw.mobi.events.CloseBrowserEvent;
import com.grw.mobi.lists.CardDashboardAdapter;
import com.grw.mobi.lists.CardItem;
import com.grw.mobi.lists.CardItemCheckin;
import com.grw.mobi.lists.CardItemRecentPresentations;
import com.grw.mobi.models.AppRole;
import com.grw.mobi.systemservices.SyncScheduler;
import com.grw.mobi.util.LocUtils;
import com.grw.mobi.util.NavUtils;

import org.acra.ACRA;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class StartActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(StartActivity.class);

    // models
    @NonNull List<CardItem> cardItems = new ArrayList<>();

    // views
    RecyclerView start_db_recycler;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_activity_dl);
        logger.debug("onCreate");
        if (! runFilters()) return;
        findViews();
        refreshUI(true);

        SyncScheduler.checkSyncAlarm(getApplicationContext());
    }

    @Override
    public void refreshUI(boolean restorePosition) {
        if (! isChecked()) return;
        loadModels();
        updateViews();
    }

    @Override
    public void onResume() {
        super.onResume();
        checkPermissions(true);
        checkPermissionApps();
    }

    @Override
    protected void permissionsDenied() {
        finish();
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEvent(CloseBrowserEvent event) {
        logger.debug("CloseBrowserEvent");
        refreshUI(false);
    }

    void loadModels() {
        logger.debug("loadModels");
        try {
            cardItems.clear();
            AppRole appRole = mSession.assignment().appRole();
            if (appRole.cap_presenter) {
                cardItems.add(new CardItemRecentPresentations(this, orm, mSession, mConfig));
            }
            if (appRole.cap_location) {
                cardItems.add(new CardItemCheckin(this, orm, mSession));
            }

        } catch (Exception ex) {
            if (Config.DEBUG) {
                throw ex;
            }
            ACRA.getErrorReporter().handleSilentException(ex);
            Toast.makeText(this, R.string.db_loading_error, Toast.LENGTH_LONG).show();
        }
    }

    void findViews() {
        start_db_recycler = (RecyclerView) findViewById(R.id.start_db_recycler);
        start_db_recycler.addItemDecoration(new CardDashboardAdapter.SpacesItemDecoration(this, 4));
    }

    void updateViews() {
        try {
            int cols = getResources().getInteger(R.integer.dashboard_columns_count);
            StaggeredGridLayoutManager gridLayoutManager =
                    new StaggeredGridLayoutManager(cols, StaggeredGridLayoutManager.VERTICAL);
            CardDashboardAdapter cardDashboardAdapter = new CardDashboardAdapter(this, cardItems);
            start_db_recycler.setLayoutManager(gridLayoutManager);
            start_db_recycler.setAdapter(cardDashboardAdapter);

        } catch (Exception ex) {
            if (Config.DEBUG) {
                throw ex;
            }
            ACRA.getErrorReporter().handleSilentException(ex);
            Toast.makeText(this, R.string.db_loading_error, Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.start, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.start_email_help:
                NavUtils.sendEmail(this, getString(R.string.app_email_help_addr));
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

    void checkPermissionApps() {
        LocUtils.checkPermissionApps(getApplicationContext(), getTracker());
    }

}
