package com.grw.mobi.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.grw.mobi.BuildConfig;
import com.grw.mobi.Config;
import com.grw.mobi.R;
import com.grw.mobi.events.DataSyncEvent;
import com.grw.mobi.events.RepoSyncEvent;
import com.grw.mobi.services.DataService;
import com.grw.mobi.services.LocationTimeService;
import com.grw.mobi.systemservices.SyncService;
import com.grw.mobi.util.DateUtils;
import com.grw.mobi.util.LocUtils;
import com.grw.mobi.util.NavUtils;
import com.grw.mobi.util.NetUtils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Date;

public class InfoActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(InfoActivity.class);

    // views
    TextView tvLoggedAs;
    TextView tvCompany;
    TextView tvDataSyncAt;
    Button syncBtn;
    View syncBtnSep;
    ProgressBar syncProgress;
    TextView syncProgressInfo;
    TextView appVersionView;
    Button advancedBtn;
    Button resetAgpsBtn;
    Button fullSyncBtn;
    View advancedSep;

    // helpers
    DataSyncEvent.Status mDataStatus;
    RepoSyncEvent.Status mRepoStatus;
    String mRepoProgressInfo;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.info_activity_dl);
        logger.debug("onCreate");

        findViews();
        updateViews();
    }

    @Override
    public void onResume() {
        super.onResume();
        updateViews();
    }

    void findViews() {
        tvLoggedAs = (TextView)findViewById(R.id.info_logged_as);
        tvCompany = (TextView)findViewById(R.id.info_logged_company);
        tvDataSyncAt = (TextView)findViewById(R.id.info_data_sync);
        syncBtn = (Button) findViewById(R.id.info_btn_sync);
        syncBtnSep = findViewById(R.id.info_btn_sync_sep);
        syncProgress = (ProgressBar) findViewById(R.id.info_sync_progress_bar);
        syncProgressInfo = (TextView) findViewById(R.id.info_sync_progress_info);
        appVersionView = (TextView) findViewById(R.id.info_app_version);
        advancedBtn = (Button) findViewById(R.id.info_advanced_btn);
        resetAgpsBtn = (Button) findViewById(R.id.info_reset_agps);
        fullSyncBtn = (Button) findViewById(R.id.info_full_sync);
        advancedSep = findViewById(R.id.info_advanced_separator);
    }

    void updateViews() {
        tvLoggedAs.setText(mConfig.getString("user_email"));
        tvCompany.setText(mConfig.getCompanyAndDomain());

        Date dataSync = orm.syncInfoDao.getInstance().last_load_at;
        if (dataSync != null) {
            String syncAt = DateUtils.sWeekDayDateTime.format(dataSync);
            tvDataSyncAt.setText(syncAt);
        } else {
            tvDataSyncAt.setText(R.string.info_data_sync_empty);
        }

        if (mDataStatus == DataSyncEvent.Status.RUNNING || mRepoStatus == RepoSyncEvent.Status.RUNNING) {
            syncBtn.setVisibility(View.GONE);
            syncBtnSep.setVisibility(View.GONE);

            syncProgress.setVisibility(View.VISIBLE);
            if (mRepoProgressInfo != null) {
                syncProgressInfo.setVisibility(View.VISIBLE);
                syncProgressInfo.setText(mRepoProgressInfo);
            } else {
                syncProgressInfo.setVisibility(View.GONE);
            }
        } else {
            syncBtn.setVisibility(View.VISIBLE);
            syncBtnSep.setVisibility(View.VISIBLE);

            syncProgress.setVisibility(View.GONE);
            syncProgressInfo.setVisibility(View.GONE);
        }

        String version = NetUtils.getPackageInfo(this).versionName;
        version += " " + BuildConfig.FLAVOR + " (" + BuildConfig.GIT_SHA + ")";
        if (Config.DEBUG) {
            version += " debug";
        }
        appVersionView.setText(version);
    }

    public void onLogout(View v) {
        logger.debug("onLogout");
        DataService ds = new DataService(getApplicationContext(), mConfig, orm);
        if (ds.shouldUpload()) {
            logger.debug("onLogout shouldUpload");
            Toast.makeText(this, R.string.info_sync_before_logout, Toast.LENGTH_LONG).show();
            return;
        }

        mSession.logout();
        orm.createTables(true);

        NavUtils.goLoginActivity(this);
    }

    public void onDataSync(View v) {
        if (! NetUtils.isOnline(getApplicationContext())) {
            Toast.makeText(this, R.string.login_while_no_network, Toast.LENGTH_LONG).show();
            return;
        }
        if (mDataStatus == DataSyncEvent.Status.RUNNING) {
            Toast.makeText(this, R.string.info_sync_in_progreess, Toast.LENGTH_LONG).show();
        }

        final Intent intent = new Intent(Intent.ACTION_SYNC, null, this, SyncService.class);
        startService(intent);
    }

    public void onShowAdvanced(View unused) {
        advancedBtn.setVisibility(View.GONE);
        resetAgpsBtn.setVisibility(View.VISIBLE);
        fullSyncBtn.setVisibility(View.VISIBLE);
        advancedSep.setVisibility(View.VISIBLE);

        // debugging helper
        LocationTimeService.computeTimes(orm, mSession.assignment().mid, new Date());
    }

    public void onFullSync(View v) {
        Intent i = new Intent(this, FullSyncActivity.class);
        i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(i);
        finish();
    }

    public void onResetAGPS(View v) {
        if (! NetUtils.isOnline(getApplicationContext())) {
            Toast.makeText(this, R.string.info_reset_agps_no_network, Toast.LENGTH_LONG).show();
            return;
        }
        if (LocUtils.resetAGPS(getApplicationContext())) {
            Toast.makeText(this, R.string.info_reset_apgs_ok, Toast.LENGTH_LONG).show();
        } else {
            Toast.makeText(this, R.string.info_reset_apgs_failed, Toast.LENGTH_LONG).show();
        }
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN, sticky = true)
    public void onEvent(DataSyncEvent event) {
        mDataStatus = event.status;
        String message = null;
        logger.debug("onEvent DataSyncEvent {}", mDataStatus);

        switch (mDataStatus) {
            case RUNNING:
                break;

            case SUCCESS:
                message = getString(R.string.info_sync_ok);
                break;

            case NET_ERROR:
                message = getString(R.string.info_sync_net_error);
                break;

            case UPGRADE_ERROR:
                logger.debug("redirect to upgrade");
                startActivity(new Intent(this, UpgradeActivity.class));
                finish();
                break;

            default:
                message = getString(R.string.info_sync_failed);
                break;
        }

        if (mDataStatus != DataSyncEvent.Status.RUNNING) {
            EventBus.getDefault().removeStickyEvent(DataSyncEvent.class);
        }

        if (message != null && event.recent()) {
            Toast.makeText(this, message, Toast.LENGTH_LONG).show();
        }
        updateViews();
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN, sticky = true)
    public void onEvent(RepoSyncEvent event) {
        mRepoStatus = event.status;
        logger.debug("onEvent RepoSyncEvent {}", mRepoStatus);
        mRepoProgressInfo = null;
        String message = null;

        switch (mRepoStatus) {
            case RUNNING:
                mRepoProgressInfo = event.progressInfo;
                break;

            case SUCCESS:
                message = getString(R.string.info_sync_repo_ok);
                break;

            case NET_ERROR:
                message = getString(R.string.info_sync_repo_net_error);
                break;

            default:
                message = getString(R.string.info_sync_repo_failed);
                break;
        }

        if (mRepoStatus != RepoSyncEvent.Status.RUNNING) {
            EventBus.getDefault().removeStickyEvent(RepoSyncEvent.class);
        }

        if (message != null && event.recent()) {
            Toast.makeText(this, message, Toast.LENGTH_LONG).show();
        }
        updateViews();
    }

}
