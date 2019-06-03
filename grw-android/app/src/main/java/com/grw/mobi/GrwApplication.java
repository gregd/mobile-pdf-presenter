package com.grw.mobi;

import android.app.Application;
import android.content.Context;
import android.widget.Toast;

import com.grw.mobi.aorm.OrmDatabase;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.services.RepoService;
import com.grw.mobi.trackers.TrackerApp;
import com.grw.mobi.trackers.TrackerFile;
import com.grw.mobi.util.ImgUtils;
import com.grw.mobi.util.LocUtils;

import org.acra.ACRA;
import org.acra.annotation.ReportsCrashes;
import org.greenrobot.eventbus.EventBus;
import org.osmdroid.config.Configuration;
import org.osmdroid.config.IConfigurationProvider;
import org.osmdroid.tileprovider.constants.OpenStreetMapTileProviderConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import static org.acra.ReportField.*;
import static org.acra.ReportField.SETTINGS_SECURE;
import static org.acra.ReportField.SETTINGS_SYSTEM;

@ReportsCrashes(
        sharedPreferencesName = "main",
        sharedPreferencesMode = Context.MODE_PRIVATE,
        applicationLogFile = "app.log",
        applicationLogFileLines = 200,
        customReportContent = { REPORT_ID, APP_VERSION_CODE, APP_VERSION_NAME, DEVICE_ID, APPLICATION_LOG,
                PACKAGE_NAME, FILE_PATH, PHONE_MODEL, BRAND, PRODUCT, ANDROID_VERSION, BUILD, TOTAL_MEM_SIZE,
                AVAILABLE_MEM_SIZE, CUSTOM_DATA, IS_SILENT, STACK_TRACE, INITIAL_CONFIGURATION, CRASH_CONFIGURATION,
                DISPLAY, USER_COMMENT, USER_EMAIL, USER_APP_START_DATE, USER_CRASH_DATE, DUMPSYS_MEMINFO, LOGCAT,
                INSTALLATION_ID, DEVICE_FEATURES, ENVIRONMENT, SHARED_PREFERENCES, SETTINGS_SYSTEM, SETTINGS_SECURE },
        formUri = "https://example.grw.com/exception")
public class GrwApplication extends Application {
    private static final Logger logger = LoggerFactory.getLogger(GrwApplication.class);

    @Override
    public void onCreate() {
        super.onCreate();

        if (! Config.DEBUG) {
            ACRA.init(this);

            ch.qos.logback.classic.Logger root = (ch.qos.logback.classic.Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
            root.detachAppender("logcat");
        }

        logger.debug("onCreate --- {}", new Date());
        Config config = Config.getInstance(getApplicationContext());

        if (! Config.DEBUG) {
            ACRA.getErrorReporter().putCustomData("git_sha", BuildConfig.GIT_SHA);
            ACRA.getErrorReporter().putCustomData("build_time", BuildConfig.BUILD_TIME);
            ACRA.getErrorReporter().putCustomData("last_user_id", String.valueOf(config.getLastUserId()));
            ACRA.getErrorReporter().putCustomData("last_company", config.getCompany() != null ? config.getCompany() : "not_set");

            EventBus.builder().
                    logNoSubscriberMessages(false).
                    sendNoSubscriberEvent(false).
                    installDefaultEventBus();
        }

        try {
            RepoService.initDirs(getApplicationContext());
            ImgUtils.initDirectory(getApplicationContext());

        } catch (IOException ex) {
            if (Config.DEBUG) throw new RuntimeException("Cannot initialize dirs", ex);
            logger.error("app_error_dir {}", ex.getMessage());
            Toast.makeText(this, R.string.app_error_ext_dir, Toast.LENGTH_LONG).show();
        }

        File osmCache = new File(getFilesDir(), "osmdroid").getAbsoluteFile();
        File osmTiles = new File(osmCache, "tiles");
        osmTiles.mkdirs();
        IConfigurationProvider osmConfig = Configuration.getInstance();
        osmConfig.setUserAgentValue("com.grw.mobi");
        osmConfig.setOsmdroidBasePath(osmCache);
        osmConfig.setOsmdroidTileCache(osmTiles);

        // init db, create db tables
        OrmDatabase.initialize(getApplicationContext());
        OrmSession ormSession = OrmDatabase.getInstance().defaultSession();

        TrackerApp trackerApp = TrackerApp.getInstance(getApplicationContext(), ormSession, config);
        trackerApp.setUaId(config.getUserRoleId(), config.getMobileDeviceId());
        TrackerFile trackerFile = TrackerFile.getInstance(getApplicationContext(), ormSession, config);
        trackerFile.setUaId(config.getUserRoleId(), config.getMobileDeviceId());

        ormSession.mobileTimeChangeDao.registerEvent(getApplicationContext(), "app_start");

        trackerApp.setScreen(getClass().getSimpleName());
        LocUtils.checkPermissionApps(getApplicationContext(), trackerApp);
    }

    @Override
    public void onTerminate() {
        OrmDatabase.dispose();
        super.onTerminate();
    }

}
