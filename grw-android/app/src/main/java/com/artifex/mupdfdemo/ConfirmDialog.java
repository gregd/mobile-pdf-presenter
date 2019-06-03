package com.artifex.mupdfdemo;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;

import com.grw.mobi.R;

public class ConfirmDialog extends DialogFragment {
    private static final String TEXT = "potwierdzam";

    public interface OnConfirmListener {
        void onConfirm(boolean confirm, boolean reopen);
    }

    OnConfirmListener listener;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        listener = (OnConfirmListener) activity;
    }

    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Activity activity = getActivity();

        LayoutInflater inflater = activity.getLayoutInflater();
        View v = inflater.inflate(R.layout.mupdf_confirm_dialog, null);
        final EditText et = (EditText) v.findViewById(R.id.mupdf_confirm_text);

        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(activity);
        alertDialogBuilder.setTitle(R.string.browser_no_context);
        alertDialogBuilder.setMessage(R.string.browser_confirm);
        alertDialogBuilder.setView(v);
        alertDialogBuilder
                .setCancelable(false)
                .setPositiveButton("Ok",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                if (listener != null) {
                                    boolean reopen = ! TEXT.equals(et.getText().toString());
                                    listener.onConfirm(true, reopen);
                                }
                            }
                        })
                .setNegativeButton("Anuluj",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                if (listener != null) {
                                    listener.onConfirm(false, false);
                                }
                            }
                        });
        return alertDialogBuilder.create();
    }

}
