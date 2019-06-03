package com.grw.mobi.ui;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AlertDialog;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SimpleMessageDialog extends DialogFragment {
    private static final Logger logger = LoggerFactory.getLogger(SimpleMessageDialog.class);

    String message;

    public SimpleMessageDialog() {}

    @Override @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Context context = getActivity();
        logger.debug("onCreateDialog");

        message = getArguments().getString("message");

        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(context);
        alertDialogBuilder.setMessage(message);
        alertDialogBuilder
                .setCancelable(false)
                .setPositiveButton("OK",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {}
                        });
        return alertDialogBuilder.create();
    }

}
