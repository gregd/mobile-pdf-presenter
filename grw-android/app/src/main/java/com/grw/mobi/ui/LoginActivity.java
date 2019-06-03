package com.grw.mobi.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
import android.support.design.widget.TextInputLayout;
import android.text.Html;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.grw.mobi.R;
import com.grw.mobi.events.LoginEvent;
import com.grw.mobi.models.SyncInfo;
import com.grw.mobi.systemservices.LoginService;
import com.grw.mobi.trackers.TrackerFile;
import com.grw.mobi.util.NetUtils;
import com.grw.mobi.util.StringSimplifier;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LoginActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(LoginActivity.class);

    // views
    TextInputLayout ilCompany;
    TextInputEditText etCompany;
    TextInputEditText etEmail;
    TextInputLayout ilEmail;
    TextInputEditText etPassword;
    TextInputLayout ilPassword;
    ProgressBar progressBar;
    TextView message;
    Button loginBtn;
    TextView accountInfo;

    // helpers
    LoginEvent lastEvent = new LoginEvent();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_activity);
        logger.debug("onCreate");
        mCheckLogin = false;
        mCheckSync = false;

        findViews();
        updateUI();
    }

    @Override
    public void onResume() {
        super.onResume();

        if (! NetUtils.isOnline(getApplicationContext())) {
            Toast.makeText(this, R.string.login_while_no_network, Toast.LENGTH_LONG).show();
        }
    }

    void findViews() {
        etCompany = (TextInputEditText) findViewById(R.id.login_company);
        ilCompany = (TextInputLayout) findViewById(R.id.login_company_layout);
        etEmail = (TextInputEditText) findViewById(R.id.login_email);
        ilEmail = (TextInputLayout) findViewById(R.id.login_email_layout);
        etPassword = (TextInputEditText) findViewById(R.id.login_password);
        ilPassword = (TextInputLayout) findViewById(R.id.login_password_layout);
        progressBar = (ProgressBar) findViewById(R.id.login_progress_bar);
        message = (TextView) findViewById(R.id.login_result_message);
        loginBtn = (Button) findViewById(R.id.login_btn_login);
        accountInfo = (TextView) findViewById(R.id.login_account_info);
    }

    @Override
    public void refreshUI(boolean restorePosition) {
        // Nothing to refresh
    }

    public void updateUI() {
        accountInfo.setText(Html.fromHtml(getString(R.string.login_account_info)));
        accountInfo.setMovementMethod(LinkMovementMethod.getInstance());

        if (lastEvent.isRunning()) {
            loginBtn.setVisibility(View.GONE);
            progressBar.setVisibility(View.VISIBLE);
            message.setVisibility(View.VISIBLE);
            message.setText(R.string.login_sending_data);
            return;
        }

        loginBtn.setVisibility(View.VISIBLE);
        progressBar.setVisibility(View.GONE);
        message.setVisibility(View.GONE);

        if (! lastEvent.hasError()) return;

        switch (lastEvent.status) {
            case LOGIN_ERROR:
                if (lastEvent.stage == LoginEvent.Stage.ACCOUNT) {
                    //ilCompany.setErrorEnabled(true);
                    ilCompany.setError(lastEvent.reason);

                } else {
                    message.setVisibility(View.VISIBLE);
                    message.setText(lastEvent.reason);
                }
                break;

            case NET_ERROR:
                message.setVisibility(View.VISIBLE);
                message.setText(R.string.login_error_net);
                break;
        }

    }

    @Override
    protected void permissionsMessage(String message) {
        this.message.setVisibility(View.VISIBLE);
        this.message.setText(message);
    }

    @Override
    protected void permissionsAccepted() {
        onLogin(null);
    }

    public void onLogin(View v) {
        logger.debug("onLogin");
        if (! checkPermissions(true)) {
            return;
        }

        String userCompany = StringSimplifier.simplify(etCompany.getText().toString()).replace(" ", "");
        String userEmail = etEmail.getText().toString();
        String userPassword = etPassword.getText().toString();

        if (userCompany.length() == 0) {
            ilCompany.setError(getString(R.string.login_error_company));
            return;
        } else {
            ilCompany.setError(null);
        }

        if (userEmail.length() == 0) {
            ilEmail.setError(getString(R.string.login_error_email));
            return;
        } else {
            ilEmail.setError(null);
        }

        if (userPassword.length() == 0) {
            ilPassword.setError(getString(R.string.login_error_password));
            return;
        } else {
            ilPassword.setError(null);
        }

        if (lastEvent.isRunning()) {
            Toast.makeText(this, R.string.login_error_in_progress, Toast.LENGTH_LONG).show();
            return;
        }

        mConfig.setString("user_company", userCompany);
        mConfig.setString("user_email", userEmail);

        final Intent intent = new Intent(Intent.ACTION_SYNC, null, this, LoginService.class);
        intent.putExtra(LoginService.EXTRA_PASSWORD, userPassword);
        startService(intent);
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN, sticky = true)
    public void onEvent(LoginEvent event) {
        logger.debug("onEvent {} {}", event.status, event.reason);
        lastEvent = event;

        if (! lastEvent.isSuccessful()) {
            updateUI();
            return;
        }

        trackerApp.setUaId(mConfig.getUserRoleId(), mConfig.getMobileDeviceId());
        trackerApp.addMissingData();
        TrackerFile trackerFile = TrackerFile.getInstance(getApplicationContext(), orm, mConfig);
        trackerFile.setUaId(mConfig.getUserRoleId(), mConfig.getMobileDeviceId());
        orm.mobileTimeChangeDao.addMissingData(mConfig.getMobileDeviceId());

        Toast.makeText(this, R.string.login_successful, Toast.LENGTH_LONG).show();
        EventBus.getDefault().removeStickyEvent(LoginEvent.class);
        finish();

        SyncInfo si = orm.syncInfoDao.getInstance();
        if (si.isDbEmpty()) {
            Intent intent = new Intent(this, FullSyncActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(FullSyncActivity.EXTRA_AUTO_START, true);
            startActivity(intent);
            finish();

        } else {
            Intent intent = new Intent(this, StartActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
        }
    }

}
