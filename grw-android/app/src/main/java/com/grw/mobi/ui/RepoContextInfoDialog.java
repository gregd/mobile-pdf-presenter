package com.grw.mobi.ui;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;

import com.grw.mobi.R;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RepoContextInfoDialog extends GrwDialog {
    private static final Logger logger = LoggerFactory.getLogger(RepoContextInfoDialog.class);

    @Override @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Context context = getActivity();
        logger.debug("onCreateDialog");

        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(context);
        alertDialogBuilder
                .setTitle(R.string.browser_info_dialog_title)
                .setMessage(R.string.browser_info_dialog_message)
                .setIcon(R.drawable.presentation_play_grey)
                .setPositiveButton(R.string.browser_info_dialog_ok,
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int id) {
                            }
                        });
        return alertDialogBuilder.create();
    }

}
