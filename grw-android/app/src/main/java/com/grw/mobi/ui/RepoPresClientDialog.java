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

public class RepoPresClientDialog extends GrwDialog {
    private static final Logger logger = LoggerFactory.getLogger(RepoPresClientDialog.class);

    @Override @NonNull
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Context context = getActivity();
        logger.debug("onCreateDialog");

        String message = null;
        String clientType = getArguments().getString("client_type");
        String clientUuid = getArguments().getString("client_uuid");

//        if (clientType != null && clientUuid != null) {
//            switch (clientType) {
//                case "Person":
//                    Person person = orm.personDao.find(clientUuid);
//                    PersonPresenter presenter = new PersonPresenter(session.assignment(), person);
//                    message = presenter.titleFullNameMainSpec();
//                    break;
//
//                case "Institution":
//                    Institution inst = orm.institutionDao.find(clientUuid);
//                    InstPresenter instPresenter = new InstPresenter(session.assignment(), inst);
//                    message = instPresenter.fullName();
//                    break;
//            }
//        }

        if (message == null) {
            message = getString(R.string.browser_pres_dialog_not_found);
        }

        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(context);
        alertDialogBuilder
                .setMessage(message)
                .setTitle(R.string.browser_pres_dialog_title)
                .setPositiveButton(R.string.browser_pres_dialog_ok,
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int id) {
                            }
                        });
        return alertDialogBuilder.create();
    }
}
