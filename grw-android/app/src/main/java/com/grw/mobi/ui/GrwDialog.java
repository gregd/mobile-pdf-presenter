package com.grw.mobi.ui;

import android.app.Activity;
import android.support.v4.app.DialogFragment;

import com.grw.mobi.Session;
import com.grw.mobi.aorm.OrmDatabase;
import com.grw.mobi.aorm.OrmSession;

public class GrwDialog extends DialogFragment {
    protected Session session;
    protected OrmSession orm;

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        orm = OrmDatabase.getInstance().defaultSession();
        session = Session.getInstance(getActivity().getApplicationContext());
    }

}
