package com.grw.mobi.ui;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.grw.mobi.R;
import com.grw.mobi.events.ApkDownloadEvent;
import com.grw.mobi.services.ApkService;
import com.grw.mobi.systemservices.UpgradeService;
import com.grw.mobi.util.NetUtils;
import com.grw.mobi.util.UIUtils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UpgradeActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(UpgradeActivity.class);

    private enum Status {
        RUNNING,
        SUCCESS,
        NET_ERROR,
        INSTALL,
        COMPANY_INSTALLER }

    // views
    TextView message;
    ProgressBar progress;
    Button btn;

    // helpers
    Status mStatus = Status.SUCCESS;
    @Nullable ApkService apkService;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.upgrade_activity);
        mCheckUpgrade = false;
        mCheckSync = false;
        logger.debug("onCreate");
        findViews();

        mStatus = Status.COMPANY_INSTALLER;

        updateUI();
    }

    void findViews() {
        message = (TextView) findViewById(R.id.upgrade_message);
        progress = (ProgressBar) findViewById(R.id.upgrade_progress);
        btn = (Button) findViewById(R.id.upgrade_btn);
    }

    public void updateUI() {
        switch (mStatus) {
            case SUCCESS:
                progress.setVisibility(View.GONE);
                btn.setVisibility(View.VISIBLE);

                message.setText(R.string.upgrade_introduction);
                btn.setText(R.string.upgrade_start_download);
                break;

            case INSTALL:
                progress.setVisibility(View.GONE);
                btn.setVisibility(View.VISIBLE);

                message.setText(R.string.upgrade_install);
                btn.setText(R.string.upgrade_accept_install);
                break;

            case RUNNING:
                progress.setVisibility(View.VISIBLE);
                btn.setVisibility(View.GONE);

                message.setText(R.string.upgrade_downloading);
                break;

            case NET_ERROR:
                btn.setVisibility(View.VISIBLE);
                progress.setVisibility(View.GONE);

                message.setText(R.string.upgrade_download_error);
                break;

            case COMPANY_INSTALLER:
                progress.setVisibility(View.GONE);
                message.setText(R.string.upgrade_installer_playstore);
                btn.setText(R.string.upgrade_installer_playstore_btn);
                btn.setVisibility(View.VISIBLE);
                break;
        }
    }

    public void onStartDownload(View v) {
        logger.debug("onStartDownload");
        if (mStatus == Status.COMPANY_INSTALLER) {
            final String name = getPackageName();
            logger.debug("onBtnOne goto market {}", name);
            try {
                startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + name)));
            } catch (android.content.ActivityNotFoundException ex) {
                startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + name)));
            }
            return;
        }
        if (mStatus == Status.RUNNING) {
            Toast.makeText(this, R.string.upgrade_download_in_progress, Toast.LENGTH_LONG).show();
            return;
        }
        if (apkService != null && apkService.isApkDownloaded()) {
            triggerInstall(apkService.getApkUri());

        } else {
            final Intent intent = new Intent(Intent.ACTION_SYNC, null, this, UpgradeService.class);
            startService(intent);
        }
    }

    private void triggerInstall(Uri apk) {
        logger.debug("triggerInstall {}", apk);

        // 1. Code might use also EXTRA_NOT_UNKNOWN_SOURCE but this requires to run
        //    startActivityForResult and be installed as system app.
        // 2. ACTION_VIEW is used when API version < 14
        UIUtils.clearUpgradeNotification(getApplicationContext());
        Intent i = new Intent(Intent.ACTION_INSTALL_PACKAGE);
        i.setDataAndType(apk, "application/vnd.android.package-archive");
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(i);
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN, sticky = true)
    public void onEvent(ApkDownloadEvent event) {
        logger.debug("onEvent {}", mStatus);

        if (event.status != ApkDownloadEvent.Status.RUNNING)
            EventBus.getDefault().removeStickyEvent(ApkDownloadEvent.class);

        switch (event.status) {
            case RUNNING:
                mStatus = Status.RUNNING;
                break;
            case SUCCESS:
                mStatus = Status.SUCCESS;
                break;
            case NET_ERROR:
                mStatus = Status.NET_ERROR;
                break;
        }

        if (mStatus == Status.SUCCESS) {
            mStatus = Status.INSTALL;
            triggerInstall(event.uri);
        }

        updateUI();
    }

}