package com.grw.mobi.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.grw.mobi.R;
import com.grw.mobi.events.DataEvent;
import com.grw.mobi.models.GeneralComment;
import com.grw.mobi.util.Utils;

import org.greenrobot.eventbus.EventBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GeneralCommentActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(GeneralCommentActivity.class);

    // params
    String mCommentableUuid;
    String mPrompt;

    // models
    GeneralComment mComment;

    // views
    TextView general_comment_prompt;
    EditText general_comment_edit;

    // helpers
    boolean mDontSaveOnPause = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.general_comment_activity_dl);
        logger.debug("onCreate");

        Intent i = getIntent();
        mCommentableUuid = i.getStringExtra("commentable_uuid");
        mPrompt = i.getStringExtra("prompt");

        findViews();
        refreshUI(true);
    }

    @Override
    public void refreshUI(boolean restorePosition) {
        loadModels();
        updateViews();
    }

    private void findViews() {
        general_comment_prompt = (TextView) findViewById(R.id.general_comment_prompt);
        general_comment_edit = (EditText) findViewById(R.id.general_comment_edit);
    }

    void loadModels() {
        mComment = orm.generalCommentDao.find(mCommentableUuid);
    }

    void updateViews() {
        general_comment_prompt.setText(mPrompt);
        general_comment_edit.setText(mComment.comments);
    }

    void updateModels() {
        String notes = general_comment_edit.getText().toString();
        mComment.comments = Utils.isBlank(notes) ? null : notes;
    }

    void saveModels() {
        updateModels();

        if (! mComment.userFieldsChanged()) {
            mDontSaveOnPause = true;
            finish();
            return;
        }

        mComment.saveWithTimestamps();
        logger.debug("comments saved");

        Toast.makeText(this, R.string.general_comment_saved, Toast.LENGTH_SHORT).show();
        mDontSaveOnPause = true;
        finish();

        EventBus.getDefault().post(new DataEvent());
    }

    @Override
    public void onResume() {
        super.onResume();
        mDontSaveOnPause = false;
    }

    @Override
    public void onPause() {
        super.onPause();
        if (mDontSaveOnPause) return;
        saveModels();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.general_comment, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.general_comment_save:
                saveModels();
                break;
        }

        return super.onOptionsItemSelected(item);
    }

}
