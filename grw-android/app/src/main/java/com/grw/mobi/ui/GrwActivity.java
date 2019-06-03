package com.grw.mobi.ui;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.SystemClock;
import android.support.annotation.LayoutRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.text.format.DateUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.grw.mobi.Config;
import com.grw.mobi.R;
import com.grw.mobi.Session;
import com.grw.mobi.aorm.OrmDatabase;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.events.DataEvent;
import com.grw.mobi.models.AppRole;
import com.grw.mobi.models.SyncInfo;
import com.grw.mobi.systemservices.SyncScheduler;
import com.grw.mobi.trackers.HitAppEvent;
import com.grw.mobi.trackers.TrackerApp;
import com.grw.mobi.util.NavUtils;
import com.grw.mobi.util.NetUtils;
import com.grw.mobi.util.Utils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Date;

public abstract class GrwActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {
    private static final Logger logger = LoggerFactory.getLogger(GrwActivity.class);

    public static final int NO_RECORD_ID = -1;
    private static final int PERMISSIONS_REQUEST = 1;

    private static boolean sSomeActivityActive = false;
    private static long sActiveFrom = 0;

    protected boolean mCheckUpgrade = true;
    protected boolean mCheckLogin = true;
    protected boolean mCheckSync = true;
    protected boolean mCheckPlayServices = false;   // Play Services is only used in few activates
    protected boolean mIsChecked = false;

    protected long mResumedFrom = 0;
    protected boolean mActivityPaused = true;
    protected boolean mReloadData = false;
    protected Config mConfig;
    protected Session mSession;
    protected OrmSession orm;
    protected TrackerApp trackerApp;
    protected boolean mAllowTracker = true;

    protected Toolbar mToolbar;
    protected DrawerLayout mDrawerLayout;
    protected ActionBarDrawerToggle mDrawerToggle;

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEvent(DataEvent event) {
        if (isFinishingOrDestroyed()) {
            mReloadData = false;
            return;
        }
        if (mActivityPaused) {
            mReloadData = true;
        } else {
            refreshUI(true);
        }
    }

    public boolean isFinishingOrDestroyed() {
        return isFinishing() || (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1 && isDestroyed());
    }

    public static void setSomeActivityActive() {
        sSomeActivityActive = true;
        sActiveFrom = SystemClock.elapsedRealtime();
    }

    public static void clearSomeActivityActive() {
        sSomeActivityActive = false;
    }

    public static boolean isSomeActivityActive() {
        long now = SystemClock.elapsedRealtime();
        //noinspection SimplifiableIfStatement
        if (sSomeActivityActive && (Math.abs(now - sActiveFrom) > DateUtils.MINUTE_IN_MILLIS * 10)) {
            // the same activity is opened for a longer period, assume it is not used by a user.
            // we don't want to block sync process because of someone left open activity.
            return false;
        }
        return sSomeActivityActive;
    }

    public TrackerApp getTracker() {
        return trackerApp;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mConfig = Config.getInstance(getApplicationContext());
        orm = OrmDatabase.getInstance().defaultSession();
        mSession = Session.getInstance(getApplicationContext());
        trackerApp = TrackerApp.getInstance(getApplicationContext(), orm, mConfig);
    }

    @Override
    public void setContentView(@LayoutRes int layoutResID) {
        super.setContentView(layoutResID);
        initToolbarAndDrawer();
    }

    public void refreshUI(boolean restorePosition) {
        // override in activity which displays db data
    }

    @Override
    public void onResume() {
        super.onResume();
        setSomeActivityActive();
        mResumedFrom = sActiveFrom;
        mActivityPaused = false;
        trackerApp.setScreen(getClass().getSimpleName());

        if (! EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this);
        }

        if (! runFilters()) {
            // do not call refreshUI when user might be not logged
            return;
        }

        if (mReloadData) {
            mReloadData = false;
            refreshUI(true);
        }
    }

    @Override
    public void onPause() {
        super.onPause();

        long viewDuration = SystemClock.elapsedRealtime() - mResumedFrom;
        if (mAllowTracker) {
            trackerApp.save(new HitAppEvent.Builder().
                    setCategory("activity").
                    setAction("view").
                    setValue(viewDuration).build());
        }

        mActivityPaused = true;
        clearSomeActivityActive();
    }

    @Override
    protected void onDestroy() {
        EventBus.getDefault().unregister(this);
        super.onDestroy();
    }

    protected boolean runFilters() {
        // don't run filters many times
        if (mIsChecked) return true;

        if (mCheckUpgrade       && redirectToUpgrade())         return false;
        if (mCheckLogin         && redirectToLogin())           return false;
        if (mCheckSync          && redirectToSync())            return false;
        if (mCheckPlayServices  && redirectToPlayServices())    return false;

        mIsChecked = true;
        return true;
    }

    protected boolean isChecked() {
        return mIsChecked;
    }

    protected boolean redirectToLogin() {
        if (mConfig.isLogged()) {
            return false;

        } else {
            logger.debug("redirect to login");
            finish();
            NavUtils.goLoginActivity(this);
            return true;
        }
    }

    protected boolean redirectToSync() {
        SyncInfo si = orm.syncInfoDao.getInstance();

        if (si.isDbEmpty()) {
            logger.debug("redirect to full sync");
            finish();
            Intent intent = new Intent(this, FullSyncActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
            return true;

        } else {
            Date lastLoad = si.last_load_at;
            Date now = new Date();

            // double check to make sure the timer is on
            if (now.getTime() - lastLoad.getTime() > DateUtils.DAY_IN_MILLIS) {
                logger.debug("1 day inactivity");
                SyncScheduler.setupAlarm(getApplicationContext());
            }

            // something is wrong, notice the user
            if (now.getTime() - lastLoad.getTime() > 7 * DateUtils.DAY_IN_MILLIS) {
                logger.debug("7 days inactivity");
                Date last = mConfig.getLastRedirectToSync();
                if ((now.getTime() - last.getTime() > 10 * DateUtils.MINUTE_IN_MILLIS) &&
                        (this.getClass() != InfoActivity.class && this.getClass() != FullSyncActivity.class)) {
                    logger.debug("redirect to info");
                    mConfig.setLastRedirectToSync(now);
                    finish();
                    Intent intent = new Intent(this, InfoActivity.class);
                    startActivity(intent);
                    Toast.makeText(this, R.string.app_sync_required, Toast.LENGTH_LONG).show();
                    return true;
                }
            }
            return false;
        }
    }

    protected boolean redirectToUpgrade() {
        // TODO because of possible problem with PlayServices version, upgrade code should have higher priority
        PackageInfo info = NetUtils.getPackageInfo(getApplicationContext());
        if (mConfig.getRequiredVersion() > info.versionCode) {
            logger.debug("redirect to upgrade {}", info.versionCode);
            finish();
            Intent intent = new Intent(this, UpgradeActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            return true;

        } else {
            return false;
        }
    }

    protected boolean redirectToPlayServices() {
        GoogleApiAvailability googleAPI = GoogleApiAvailability.getInstance();
        int result = googleAPI.isGooglePlayServicesAvailable(this);
        if (result != ConnectionResult.SUCCESS) {
            logger.debug("redirect to play services");
            finish();
            Intent intent = new Intent(this, UpgradePlayServicesActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
            return true;

        } else {
            return false;
        }
    }

    protected void initToolbarAndDrawer() {
        mToolbar = (Toolbar) findViewById(R.id.main_toolbar);
        if (mToolbar == null) {
            logger.warn("XXX no toolbar in layout");
            return;
        }
        setSupportActionBar(mToolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeAsUpIndicator(null);
        }

        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (mDrawerLayout == null) {
            return;
        }
        mDrawerToggle = new ActionBarDrawerToggle(
                this, mDrawerLayout, mToolbar, R.string.app_nav_drawer_open, R.string.app_nav_drawer_close);
        mDrawerLayout.addDrawerListener(mDrawerToggle);
        mDrawerToggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.main_nav_view);
        if (navigationView == null) throw new RuntimeException("Cannot find navigationView");

        navigationView.setNavigationItemSelectedListener(this);

        View header = navigationView.getHeaderView(0);
        TextView navCompany = (TextView) header.findViewById(R.id.main_nav_company);
        TextView navTitle = (TextView) header.findViewById(R.id.main_nav_title);
        TextView navSubtitle = (TextView) header.findViewById(R.id.main_nav_subtitle);

        navCompany.setText(Utils.capitalizeFirstLetter(mConfig.getCompany()));
        if (mSession.isLoaded()) {
            navTitle.setText(mSession.user().nameSurname());
            navSubtitle.setText(mSession.assignment().name);
        } else {
            navTitle.setVisibility(View.GONE);
            navSubtitle.setVisibility(View.GONE);
        }

        boolean hideLocation = true;
        boolean hidePresenter = true;

        if (mSession.assignment() != null) {
            AppRole appRole = mSession.assignment().appRole();
            hideLocation = ! appRole.cap_location;
            hidePresenter = ! appRole.cap_presenter;
        }

        Menu menu = navigationView.getMenu();
        MenuItem item;
        if (hideLocation) {
            item = menu.findItem(R.id.main_nav_checkin);
            if (item != null) {
                item.setVisible(false);
            }
            item = menu.findItem(R.id.main_nav_locations);
            if (item != null) {
                item.setVisible(false);
            }
        }
        if (hidePresenter) {
            item = menu.findItem(R.id.main_nav_presentations);
            if (item != null) {
                item.setVisible(false);
            }
        }

    }

    @Override
    public void onBackPressed() {
        if (mDrawerLayout == null) {
            super.onBackPressed();
            return;
        }
        if (mDrawerLayout.isDrawerOpen(GravityCompat.START)) {
            mDrawerLayout.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                logger.debug("onOptionsItemSelected home");
                android.support.v4.app.NavUtils.navigateUpFromSameTask(this);
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        boolean result = true;
        int navId = item.getItemId();
        switch (navId) {
            case R.id.main_nav_start:
                tryOpenActivity(item, StartActivity.class, Intent.FLAG_ACTIVITY_CLEAR_TOP);
                break;

            case R.id.main_nav_checkin:
                tryOpenActivity(item, CheckinActivity.class, null);
                break;

            case R.id.main_nav_locations:
                tryOpenActivity(item, LocationsActivity.class, null);
                break;

            case R.id.main_nav_presentations:
                tryOpenActivity(item, RepoBrowserActivity.class, null);
                break;

            case R.id.main_nav_info:
                tryOpenActivity(item, InfoActivity.class, null);
                break;

            case R.id.main_nav_web_link:
                NavUtils.openWWW(this, mConfig.buildWebAppUrl());
                result = false;
                break;

            case R.id.main_nav_help_link:
                ArrayList<String> caps = new ArrayList<>();
                if (mSession.isLoaded()) {
                    AppRole appRole = mSession.assignment().appRole();
                    if (appRole.cap_location) {
                        caps.add("location=1");
                    }
                    if (appRole.cap_presenter) {
                        caps.add("presenter=1");
                    }
                    if (appRole.cap_projects) {
                        caps.add("projects=1");
                    }
                    if (appRole.cap_crm) {
                        caps.add("crm=1");
                    }
                } else {
                    caps.add("no_session=1");
                }
                NavUtils.openWWW(this, mConfig.buildWebInfoUrl(TextUtils.join("&", caps)));
                result = false;
                break;

            default:
                logger.warn("Unhandled nav menu item {}", navId);
        }
        mDrawerLayout.closeDrawer(GravityCompat.START);
        return result;
    }

    protected void tryOpenActivity(@NonNull MenuItem item, @NonNull Class<?> cls, @Nullable Integer flags) {
        item.setChecked(true);
        if (this.getClass() == cls) {
            return;
        }
        Intent intent = new Intent(this, cls);
        if (flags != null) {
            intent.setFlags(flags);
        }
        startActivity(intent);
    }

    public String getStringResourceByName(@NonNull String s) {
        String packageName = getPackageName();
        int resId = getResources().getIdentifier(s, "string", packageName);
        return getString(resId);
    }

    protected void setActionBarTitle(@StringRes int rid) {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar == null) return;
        actionBar.setTitle(rid);
    }

    protected void setActionBarTitle(@NonNull String s) {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar == null) return;
        actionBar.setTitle(s);
    }

    protected boolean checkPermissions(boolean askForPerms) {
        String[] required;

        required = new String[] {
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_LOCATION_EXTRA_COMMANDS,
                Manifest.permission.INTERNET,
                Manifest.permission.ACCESS_WIFI_STATE,
                Manifest.permission.ACCESS_NETWORK_STATE,
                Manifest.permission.RECEIVE_BOOT_COMPLETED,
                Manifest.permission.WAKE_LOCK };

        boolean[] grants = new boolean[required.length];
        for (int i = 0; i < required.length; i++) {
            grants[i] = ContextCompat.checkSelfPermission(this, required[i]) == PackageManager.PERMISSION_GRANTED;
        }

        int notGrantedCount = 0;
        for (int i = 0; i < required.length; i++) {
            if (! grants[i]) {
                notGrantedCount += 1;
            }
        }
        if (notGrantedCount == 0) {
            logger.debug("checkPermissions all granted");
            return true;
        }
        if (! askForPerms) {
            logger.debug("checkPermissions not granted");
            permissionsMessage(getString(R.string.app_permissions_not_accepted));
            return false;
        }

        String[] request = new String[notGrantedCount];
        int j = 0;
        for (int i = 0; i < required.length; i++) {
            if (! grants[i]) {
                request[j] = required[i];
                j += 1;
            }
        }

        logger.debug("checkPermissions request {}", (Object[]) request);
        ActivityCompat.requestPermissions(this, request, PERMISSIONS_REQUEST);
        return false;
    }

    protected void permissionsMessage(String message) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

    protected void permissionsAccepted() {
        // override in subclass that called checkPermissions
    }

    protected void permissionsDenied() {
        // override in subclass that called checkPermissions
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        logger.debug("onRequestPermissionsResult {} {} {}", requestCode, permissions, grantResults);
        switch (requestCode) {
            case PERMISSIONS_REQUEST: {
                boolean allGranted = true;
                for (int i = 0; i < permissions.length; i++) {
                    if (grantResults[i] != PackageManager.PERMISSION_GRANTED) {
                        allGranted = false;
                        break;
                    }
                }
                if (allGranted) {
                    permissionsAccepted();

                } else {
                    boolean showRationale = false;
                    for (int i = 0; i < permissions.length; i++) {
                        if (grantResults[i] == PackageManager.PERMISSION_GRANTED) continue;
                        if (ActivityCompat.shouldShowRequestPermissionRationale(this, permissions[i])) {
                            showRationale = true;
                        }
                    }
                    logger.debug("onRequestPermissionsResult showRationale {}", showRationale);
                    if (showRationale) {
                        permissionsMessage(getString(R.string.app_permissions_required));
                    } else {
                        permissionsMessage(getString(R.string.app_permissions_not_accepted));
                        permissionsDenied();
                    }
                }
                break;
            }
        }
    }

}
