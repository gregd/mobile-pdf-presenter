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

public class DoubleTextFragPicker extends DialogFragment {
    private static final Logger logger = LoggerFactory.getLogger(DoubleTextFragPicker.class);

    public interface OnDoubleTextSetListener {
        void onDoubleTextSet(String tag, String string1, String string2);
    }

    OnDoubleTextSetListener listener;
    String tag;
    String s1, s2, l1, l2, title;

    public DoubleTextFragPicker() {}

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            listener = (OnDoubleTextSetListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString() + " must implement OnDoubleTextSetListener");
        }
    }

    @Override @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Context context = getActivity();
        tag     = getArguments().getString("tag");
        s1      = getArguments().getString("string1");
        s2      = getArguments().getString("string2");
        title   = getArguments().getString("title");
        l1      = getArguments().getString("label1");
        l2      = getArguments().getString("label2");

        LayoutInflater inflater = getActivity().getLayoutInflater();
        View v = inflater.inflate(R.layout.double_text_frag, null);

        final EditText et1 = (EditText) v.findViewById(R.id.double_text_frag_s1);
        et1.setText(s1 != null ? s1 : "");
        et1.setHint(l1 != null ? l1 : "");
        if (s1 != null && s1.length() > 0) {
            et1.setSelection(s1.length());
        }

        final EditText et2 = (EditText) v.findViewById(R.id.double_text_frag_s2);
        et2.setText(s2 != null ? s2 : "");
        et2.setHint(l2 != null ? l2 : "");

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
                                    et2.clearFocus();
                                    listener.onDoubleTextSet(tag, et1.getText().toString(), et2.getText().toString());
                                }
                            }
                        })
                .setNeutralButton("Wyczyść",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                if (listener != null) {
                                    listener.onDoubleTextSet(tag, null, null);
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
