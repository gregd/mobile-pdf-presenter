package com.grw.mobi.util;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.annotation.StringRes;
import android.support.v4.app.NotificationCompat;
import android.support.v7.app.AlertDialog;

import com.grw.mobi.R;
import com.grw.mobi.ui.UpgradeActivity;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class UIUtils {
    private static final Logger logger = LoggerFactory.getLogger(UIUtils.class);

    public static final int NOTIFY_UPGRADE_ID = 1;
    public static final int NOTIFY_NO_SPACE_ID = 2;

    public static void addNoSpaceNotification(Context context) {
        CharSequence title = context.getString(R.string.browser_no_space_title);
        CharSequence content = context.getString(R.string.browser_no_space_text);

        Notification notification = new NotificationCompat.Builder(context).
                setContentTitle(title).
                setContentText(content).
                setSmallIcon(android.R.drawable.stat_sys_warning).
                setDefaults(Notification.DEFAULT_SOUND).
                build();

        NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.notify(NOTIFY_NO_SPACE_ID, notification);
    }

    public static void addUpgradeNotification(Context context) {
        Intent notificationIntent = new Intent(context, UpgradeActivity.class);
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent contentIntent = PendingIntent.getActivity(context, 0, notificationIntent, 0);
        CharSequence title = context.getString(R.string.upgrade_notification);
        CharSequence content = context.getString(R.string.upgrade_notification_long);

        Notification notification = new Notification.Builder(context).
                setContentTitle(title).
                setContentText(content).
                setSmallIcon(android.R.drawable.stat_sys_warning).
                setDefaults(Notification.DEFAULT_SOUND).
                setContentIntent(contentIntent).
                build();
        //notification.flags |= Notification.FLAG_NO_CLEAR;

        NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.notify(NOTIFY_UPGRADE_ID, notification);
    }

    public static void clearUpgradeNotification(Context context) {
        NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.cancel(UIUtils.NOTIFY_UPGRADE_ID);
    }

    public static void showErrorsDialog(Context context, @StringRes int title, List<Integer> errors) {
        String message = context.getString(title);
        for (Integer i : errors) {
            message += "\n";
            message += context.getString(i);
        }
        new AlertDialog.Builder(context)
                .setMessage(message)
                .setNeutralButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dlg, int sumthin) {}
                })
                .show();
    }

    public static void showErrorsDialog2(Context context, List<String> titleAndMessages) {
        if (titleAndMessages == null || titleAndMessages.size() == 0) {
            logger.warn("showErrorsDialog2 empty");
            return;
        }
        String title = titleAndMessages.remove(0);
        String message = "";
        for (String s : titleAndMessages) {
            if (s.length() > 0) {
                message += "\n";
            }
            message += s;
        }
        if (message.length() == 0) {
            message = null;
        }
        new AlertDialog.Builder(context)
                .setTitle(title)
                .setMessage(message)
                .setNeutralButton("OK", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dlg, int unused) {}
                })
                .show();
    }

}
