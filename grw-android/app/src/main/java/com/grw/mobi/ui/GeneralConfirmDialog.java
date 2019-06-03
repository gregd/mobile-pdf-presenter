package com.grw.mobi.ui;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AlertDialog;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GeneralConfirmDialog extends GrwDialog {
    private static final Logger logger = LoggerFactory.getLogger(GeneralConfirmDialog.class);

    public interface OnGeneralConfirmListener {
        void onGeneralConfirmSet(@NonNull String tag, @NonNull String btn);
    }

    public static GeneralConfirmDialog newInstance(@NonNull String tag,
                                                   @Nullable String title, @Nullable String message,
                                                   @Nullable String positiveBtn, @Nullable String neutralBtn, @Nullable String negativeBtn) {
        GeneralConfirmDialog f = new GeneralConfirmDialog();
        Bundle b = new Bundle();
        b.putString("tag", tag);
        if (title != null) {
            b.putString("title", title);
        }
        if (message != null) {
            b.putString("message", message);
        }
        if (positiveBtn != null) {
            b.putString("positive_btn", positiveBtn);
        }
        if (neutralBtn != null) {
            b.putString("neutral_btn", neutralBtn);
        }
        if (negativeBtn != null) {
            b.putString("negative_btn", negativeBtn);
        }
        f.setArguments(b);
        return f;
    }

    @Override @NonNull
    public Dialog onCreateDialog(Bundle bundle) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        String s = getArguments().getString("tag");
        final String tag = (s != null) ? s : "no_tag";
        String title = getArguments().getString("title");
        String message = getArguments().getString("message");
        String positiveBtn = getArguments().getString("positive_btn");
        String neutralBtn = getArguments().getString("neutral_btn");
        String negativeBtn = getArguments().getString("negative_btn");

        if (title != null) {
            builder.setTitle(title);
        }
        if (message != null) {
            builder.setMessage(message);
        }
        if (positiveBtn != null) {
            builder.setPositiveButton(positiveBtn, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    OnGeneralConfirmListener listener = (OnGeneralConfirmListener) getTargetFragment();
                    if (listener != null) {
                        listener.onGeneralConfirmSet(tag, "positive");
                    }
                }
            });
        }
        if (neutralBtn != null) {
            builder.setNeutralButton(neutralBtn, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    OnGeneralConfirmListener listener = (OnGeneralConfirmListener) getTargetFragment();
                    if (listener != null) {
                        listener.onGeneralConfirmSet(tag, "neutral");
                    }
                }
            });
        }
        if (negativeBtn != null) {
            builder.setNegativeButton(negativeBtn, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    OnGeneralConfirmListener listener = (OnGeneralConfirmListener) getTargetFragment();
                    if (listener != null) {
                        listener.onGeneralConfirmSet(tag, "negative");
                    }
                }
            });
        }

        return builder.create();
    }

}
