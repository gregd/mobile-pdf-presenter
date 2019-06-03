package com.grw.mobi.ui;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;

import com.grw.mobi.R;
import com.grw.mobi.Session;
import com.grw.mobi.aorm.OrmDatabase;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.models.LocationVisit;
import com.grw.mobi.services.LocationReportService;
import com.grw.mobi.util.DateUtils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Date;

public class Widget extends AppWidgetProvider {
    private static final Logger logger = LoggerFactory.getLogger(Widget.class);

    @Override
    public void onUpdate(Context context, AppWidgetManager mgr, int[] appWidgetIds) {
        logger.debug("onUpdate");

        OrmSession orm = OrmDatabase.getInstance().defaultSession();
        Session session = Session.getInstance(context);
        LocationReportService visitService;
        LocationVisit locationVisit = null;
        Date day = DateUtils.today();
        String workTime;
        String btnText;

        if (session.isLoaded()) {
            LocationReportService.LocationSummaryReport summaryReport;
            visitService = new LocationReportService(orm, session);
            summaryReport = visitService.locationSummaryReport(day);
            workTime = String.format(
                    context.getString(R.string.widget_visits_time),
                    DateUtils.secondsToHM(summaryReport.workSeconds));

            btnText = context.getString(R.string.widget_checkin_btn);

        } else {
            workTime = context.getString(R.string.widget_not_logged);
            btnText = context.getString(R.string.widget_do_login);
        }

        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget);

            Intent intent;
            if (session.isLoaded()) {
                intent = new Intent(context, CheckinActivity.class);
            } else {
                intent = new Intent(context, LoginActivity.class);
            }
            PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);
            views.setOnClickPendingIntent(R.id.widget_location_btn, pendingIntent);
            views.setTextViewText(R.id.widget_title, workTime);
            views.setTextViewText(R.id.widget_location_btn, btnText);

            mgr.updateAppWidget(appWidgetId, views);
        }
    }

    public static void triggerUpdate(Context context) {
        logger.debug("triggerUpdate");
        Intent intent = new Intent(context, Widget.class);
        intent.setAction("android.appwidget.action.APPWIDGET_UPDATE");
        int ids[] = AppWidgetManager.getInstance(context).getAppWidgetIds(new ComponentName(context, Widget.class));
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
        context.sendBroadcast(intent);
    }

}
