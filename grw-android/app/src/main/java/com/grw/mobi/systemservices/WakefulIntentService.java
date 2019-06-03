package com.grw.mobi.systemservices;

import android.app.IntentService;
import android.content.Context;
import android.content.Intent;
import android.os.PowerManager;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

abstract public class WakefulIntentService extends IntentService {
    private static final Logger logger = LoggerFactory.getLogger(WakefulIntentService.class);

    abstract protected void doWakefulWork(Intent intent);

    static final String NAME = "com.grw.mobi.WakefulIntentService";
    private static volatile PowerManager.WakeLock lockStatic = null;

    synchronized private static PowerManager.WakeLock getLock(Context context) {
        if (lockStatic == null) {
            PowerManager mgr=
                    (PowerManager)context.getSystemService(Context.POWER_SERVICE);

            lockStatic=mgr.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, NAME);
            lockStatic.setReferenceCounted(true);
        }

        return(lockStatic);
    }

    public static void sendWakefulWork(Context ctxt, Intent i) {
        getLock(ctxt.getApplicationContext()).acquire();
        ctxt.startService(i);
    }

    public WakefulIntentService(String name) {
        super(name);
        setIntentRedelivery(true);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        PowerManager.WakeLock lock=getLock(this.getApplicationContext());

        if (!lock.isHeld() || (flags & START_FLAG_REDELIVERY) != 0) {
            lock.acquire();
        }

        super.onStartCommand(intent, flags, startId);

        return(START_REDELIVER_INTENT);
    }

    @Override
    final protected void onHandleIntent(Intent intent) {
        try {
            doWakefulWork(intent);
        }
        finally {
            PowerManager.WakeLock lock = getLock(this.getApplicationContext());

            if (lock.isHeld()) {
                try {
                    lock.release();

                } catch (Exception e) {
                    logger.warn("Exception when releasing wakelock " + getClass().getSimpleName(), e);
                }
            }
        }
    }

}
