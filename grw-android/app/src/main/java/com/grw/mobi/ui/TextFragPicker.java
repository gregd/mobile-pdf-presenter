package com.grw.mobi.ui;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;

import com.grw.mobi.R;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TextFragPicker extends DialogFragment {
    private static final Logger logger = LoggerFactory.getLogger(TextFragPicker.class);

    public interface OnSingleTextSetListener {
        void onSingleTextSet(String tag, String string1);
    }

    OnSingleTextSetListener listener;
    String tag;
    String s1, l1, title;

    public TextFragPicker() {}

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        listener = (OnSingleTextSetListener) activity;
    }

    @Override @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Context context = getActivity();
        tag     = getArguments().getString("tag");
        s1      = getArguments().getString("string1");
        title   = getArguments().getString("title");
        l1      = getArguments().getString("label1");

        LayoutInflater inflater = getActivity().getLayoutInflater();
        View v = inflater.inflate(R.layout.single_text_frag, null);

        final EditText et1 = (EditText) v.findViewById(R.id.single_text_frag_s1);
        et1.setText(s1 != null ? s1 : "");
        et1.setHint(l1 != null ? l1 : "");
        if (s1 != null && s1.length() > 0) {
            et1.setSelection(s1.length());
        }

        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(context);
        alertDialogBuilder.setTitle(title);
        alertDialogBuilder.setView(v);
        alertDialogBuilder
                .setCancelable(false)
                .setPositiveButton("Ok",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                if (listener != null) {
                                    et1.clearFocus();
                                    listener.onSingleTextSet(tag, et1.getText().toString());
                                }
                            }
                        })
                .setNeutralButton("Wyczyść",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                if (listener != null) {
                                    listener.onSingleTextSet(tag, null);
                                }
                            }
                        })
                .setNegativeButton("Anuluj",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        });
        return alertDialogBuilder.create();
    }

}
