package com.grw.mobi.ui;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.grw.mobi.R;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UpgradePlayServicesActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(UpgradePlayServicesActivity.class);

    public static final int PLAY_SERVICES_RESULT = 100;

    TextView message;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.upgrade_play_services_activity);
        mCheckUpgrade = false;
        mCheckLogin = false;
        mCheckSync = false;

        message = (TextView) findViewById(R.id.upgrade_play_services_message);
        message.setText(R.string.app_play_services_required);
        check();
    }

    public void refreshUI(boolean restorePosition) {}

    void check() {
        GoogleApiAvailability googleAPI = GoogleApiAvailability.getInstance();
        int resultCode = googleAPI.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (googleAPI.isUserResolvableError(resultCode)) {
                String s = googleAPI.getErrorString(resultCode);
                logger.debug("GooglePlayServices recoverable error {} {}", resultCode, s);
                googleAPI.getErrorDialog(this, resultCode, PLAY_SERVICES_RESULT).show();

            } else {
                String s = googleAPI.getErrorString(resultCode);
                logger.debug("GooglePlayServices non recoverable error {} {}", resultCode, s);
                message.setText(R.string.app_play_services_unavailable);
                message.setTextColor(Color.RED);
            }

        } else {
            Toast.makeText(this, R.string.app_play_services_ok, Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(this, StartActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        logger.debug("onActivityResult request {}, result {}", requestCode, resultCode);

        if (resultCode == RESULT_CANCELED && requestCode == PLAY_SERVICES_RESULT) {
            logger.debug("onActivityResult Google Play Services error");
            message.setText(R.string.app_play_services_canceled);
            return;
        }

        check();
    }

}
