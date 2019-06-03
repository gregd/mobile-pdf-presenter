package com.grw.mobi.util;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.Toast;

import com.artifex.mupdfdemo.MuPDFActivity;
import com.grw.mobi.Config;
import com.grw.mobi.R;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.models.PresentationClient;
import com.grw.mobi.presenters.RepoFilePresenter;
import com.grw.mobi.ui.LoginActivity;
import com.grw.mobi.ui.RepoBrowserActivity;
import com.grw.mobi.ui.RepoViewHtmlActivity;
import com.grw.mobi.ui.RepoViewVideoActivity;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NavUtils {
    private static final Logger logger = LoggerFactory.getLogger(NavUtils.class);

    public static void openPresentationFor(Context context, OrmModel model, String name) {
        Config config = Config.getInstance(context);
        PresentationClient.set(config, model);

        Intent intent = new Intent(context, RepoBrowserActivity.class);
        context.startActivity(intent);
        String message = context.getString(R.string.browser_presentation_for) + name;
        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
    }

    public static void openRepoFile(Context context, RepoFilePresenter pres) {
        Intent i = new Intent();
        i.putExtra("repo_name", pres.getRepoName());
        if (pres.getRelPath() != null) {
            i.putExtra("rel_path", pres.getRelPath());
        }

        if (pres.isDir) {
            i.setClass(context, RepoBrowserActivity.class);
            context.startActivity(i);
            return;
        }
        if (pres.isHtml()) {
            i.setClass(context, RepoViewHtmlActivity.class);
            context.startActivity(i);
            return;
        }
        if (pres.isVideo()) {
            i.setClass(context, RepoViewVideoActivity.class);
            context.startActivity(i);
            return;
        }
        if (pres.isPdf()) {
            i.setClass(context, MuPDFActivity.class);
            i.setData(Uri.fromFile(pres.getFile()));
            context.startActivity(i);
            return;
        }

        Toast.makeText(context, pres.getTitle(), Toast.LENGTH_SHORT).show();
    }

    public static void callPhone(Context context, String number) {
        try {
            Intent intent = new Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + number));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } catch (Exception e) {
            // TODO log exception
            logger.error("Failed to invoke call", e);
        }
    }

    // http://stackoverflow.com/a/15022153/3315
    public static void sendEmail(Context context, String email) {
        try {
            Intent intent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", email, null));
            context.startActivity(Intent.createChooser(intent, context.getString(R.string.util_choose_send_email)));
        } catch (Exception e) {
            // TODO log exception
            logger.error("Failed to send email", e);
        }
    }

    public static void openWWW(Context context, String address) {
        if (!address.startsWith("https://") && !address.startsWith("http://")) {
            address = "http://" + address;
        }
        Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(address));
        context.startActivity(i);
    }

    public static void openWWWGrwPerson(Context context, int personId) {
        String address = Config.getInstance(context).getPersonUri(personId);
        Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(address));
        context.startActivity(i);
    }

    public static void openWWWGrwInst(Context context, int instId) {
        String address = Config.getInstance(context).getInstitutionUri(instId);
        Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse(address));
        context.startActivity(i);
    }

    public static void openNavigation(Context context, double lat, double lng) {
        String s = "http://maps.google.com/maps?daddr=" + lat + "," + lng;
        openWWW(context, s);
    }

    public static void goLoginActivity(Context context) {
        final Intent intent = new Intent(context, LoginActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

}
