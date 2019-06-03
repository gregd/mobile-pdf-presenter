package com.grw.mobi.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v7.widget.RecyclerView;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.grw.mobi.R;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.events.CloseBrowserEvent;
import com.grw.mobi.events.FilesEvent;
import com.grw.mobi.lists.ARItem;
import com.grw.mobi.lists.ARItemAdapter;
import com.grw.mobi.lists.ItemRepoFile;
import com.grw.mobi.models.PresentationClient;
import com.grw.mobi.models.TrackerFileState;
import com.grw.mobi.presenters.RepoFilePresenter;
import com.grw.mobi.services.RepoService;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class RepoBrowserActivity extends GrwActivity {
    private static final Logger logger = LoggerFactory.getLogger(RepoBrowserActivity.class);

    // params
    String repoName;
    String relPath;

    // models
    RepoService repoService;
    List<RepoFilePresenter> files;
    OrmModel presClient;

    // views
    RecyclerView browserGrid;
    TextView browserMessage;
    Button warningBtn;
    TextView barPresentation;
    Button cancelBtn;
    Button finishedBtn;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.repo_browser_activity_dl);

        Intent i = getIntent();
        repoName = i.getStringExtra("repo_name");
        if (repoName == null) {
            repoName = RepoService.REPO_MAIN;
        }
        relPath = i.getStringExtra("rel_path");
        logger.debug("onCreate {} {}", repoName, relPath);

        setActionBarTitle(buildTitle(relPath));

        loadModels();
        findViews();
        updateViews();
    }

    private String buildTitle(String relPath) {
        String title = getString(R.string.browser_title);
        if (relPath != null) {
            if (relPath.startsWith("/")) {
                relPath = relPath.substring(1);
            }
            relPath = relPath.replace("/", " > ");
            title = title + " > " + relPath;
        }
        return title;
    }

    public void refreshUI(boolean restorePosition) {
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEvent(FilesEvent event) {
        logger.debug("FilesEvent");
        loadModels();
        updateViews();
    }

    @SuppressWarnings("unused")
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEvent(CloseBrowserEvent event) {
        logger.debug("CloseBrowserEvent");
        finish();
    }

    private void loadModels() {
        repoService = new RepoService(getApplicationContext(), mConfig, orm, repoName);
        files = repoService.getDir(relPath);

        presClient = PresentationClient.get(mConfig);

        if (presClient != null) {
            for (RepoFilePresenter p : files) {
                if (p.getTrackingId() == null) continue;

                TrackerFileState state = orm.trackerFileStateDao.findFor(p.getTrackingId(), presClient);
                if (state == null) continue;

                if (state.progress != null && state.progress > 0) {
                    p.stateProgress = state.progress;
                }
            }
        }
    }

    private void findViews() {
        browserGrid = (RecyclerView) findViewById(R.id.browser_grid);
        browserMessage = (TextView) findViewById(R.id.browser_message);
        warningBtn = (Button) findViewById(R.id.browser_bar_warning);
        barPresentation = (TextView) findViewById(R.id.browser_bar_presentation);
        cancelBtn = (Button) findViewById(R.id.browser_bar_cancel_btn);
        finishedBtn = (Button) findViewById(R.id.browser_bar_finished_btn);
    }

    private void updateViews() {
        warningBtn.setVisibility(View.GONE);
        barPresentation.setVisibility(View.GONE);
        cancelBtn.setVisibility(View.GONE);
        finishedBtn.setVisibility(View.GONE);

//        if (presClient != null) {
//            warningBtn.setVisibility(View.GONE);
//            barPresentation.setVisibility(View.VISIBLE);
//            cancelBtn.setVisibility(View.VISIBLE);
//            finishedBtn.setVisibility(View.VISIBLE);
//        } else {
//            warningBtn.setVisibility(View.VISIBLE);
//            barPresentation.setVisibility(View.GONE);
//            cancelBtn.setVisibility(View.GONE);
//            finishedBtn.setVisibility(View.GONE);
//        }

        if (files == null) {
            setMessage(R.string.browser_message_no_sync);
            return;
        }

        if (files.size() == 0) {
            setMessage(R.string.browser_message_no_files);
            return;
        }

        hideMessage();

        ArrayList<ARItem> items = new ArrayList<>();
        for (RepoFilePresenter pres : files) {
            items.add(new ItemRepoFile(this, pres));
        }

        ARItemAdapter adapter = new ARItemAdapter(this, mSession, browserGrid, items, ARItemAdapter.GRID);
        browserGrid.setAdapter(adapter);
    }

    void hideMessage() {
        browserMessage.setVisibility(View.GONE);
        browserGrid.setVisibility(View.VISIBLE);
    }

    void setMessage(int resId) {
        browserGrid.setVisibility(View.GONE);
        browserMessage.setVisibility(View.VISIBLE);
        browserMessage.setText(resId);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.repo_broswer, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        MenuItem item = menu.findItem(R.id.browser_menu_client);
        item.setVisible(presClient != null);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.browser_menu_client:
                openPresClientDialog();
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }

    void openPresClientDialog() {
        DialogFragment df = new RepoPresClientDialog();
        Bundle b = new Bundle();
        b.putString("client_type", presClient.canonicalModel());
        b.putString("client_uuid", presClient.uuid);
        df.setArguments(b);
        df.show(getSupportFragmentManager(), "pres_client_dialog");
    }

    public void onPresentationCanceled(View v) {
        PresentationClient.clearAndCancel(mConfig);
        EventBus.getDefault().post(new CloseBrowserEvent());
        Toast.makeText(this, R.string.browser_stats_cancelled, Toast.LENGTH_LONG).show();
    }

    public void onPresentationFinished(View v) {
        PresentationClient.clear(mConfig);
        EventBus.getDefault().post(new CloseBrowserEvent());
        Toast.makeText(this, R.string.browser_stats_saved, Toast.LENGTH_LONG).show();
    }

    public void onPresentationWarning(View v) {
        DialogFragment df = new RepoContextInfoDialog();
        df.show(getSupportFragmentManager(), "pres_context_info_dialog");
    }

}
