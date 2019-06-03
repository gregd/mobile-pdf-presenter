package com.grw.mobi.ui;

import android.app.DialogFragment;
import android.content.Intent;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.widget.MediaController;
import android.widget.Toast;

import com.artifex.mupdfdemo.ConfirmDialog;
import com.grw.mobi.R;
import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.models.NavigationHistory;
import com.grw.mobi.models.PresentationClient;
import com.grw.mobi.models.TrackerFileState;
import com.grw.mobi.presenters.RepoFilePresenter;
import com.grw.mobi.services.RepoService;
import com.grw.mobi.trackers.HitFileEvent;
import com.grw.mobi.trackers.TrackerFile;
import com.grw.mobi.util.ObservableVideoView;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;

public class RepoViewVideoActivity extends GrwActivity implements
        ConfirmDialog.OnConfirmListener,
        MediaPlayer.OnCompletionListener,
        ObservableVideoView.VideoActionListener {
    private static final Logger logger = LoggerFactory.getLogger(RepoViewVideoActivity.class);

    // params
    String repoName;
    String relPath;
    @Nullable Integer mTrackingId;

    // models
    RepoService repoService;
    RepoFilePresenter videoPres;

    // views
    ObservableVideoView videoView;

    // helpers
    @NonNull SaveState state = new SaveState();
    @Nullable TrackerFile trackerFile;
    @Nullable HitFileEvent.Builder hitBuilder;
    @Nullable OrmModel mTrackable;

    @Override
    public void onCreate(Bundle inState) {
        super.onCreate(inState);
        setContentView(R.layout.repo_view_video_activity);

        Intent i = getIntent();
        repoName = i.getStringExtra("repo_name");
        relPath = i.getStringExtra("rel_path");
        logger.debug("onCreate {} {}", repoName, relPath);
        setActionBarTitle(buildTitle(relPath));

        RepoService service = new RepoService(getApplicationContext(), mConfig, orm, repoName);
        RepoFilePresenter pres = service.getFile(relPath);
        if (pres == null) {
            Toast.makeText(this, R.string.browser_no_file, Toast.LENGTH_LONG).show();
            finish();
            return;
        }
        NavigationHistory.remember(orm, mSession, pres);

        findViews();

        if (pres.getTrackingId() != null) {
            trackerFile = TrackerFile.getInstance(getApplicationContext(), orm, mConfig);
            mTrackingId = pres.getTrackingId();
            trackerFile.setTrackingId(mTrackingId);

            mTrackable = PresentationClient.get(mConfig);
            trackerFile.setTrackable(mTrackable);
        }

        if (inState != null && inState.containsKey("state")) {
            //noinspection ConstantConditions
            state = inState.getParcelable("state");
        } else {
            state.position = trackerGetLastPosition();
        }

//        if (pres.getTrackingId() != null && mTrackable == null) {
//            if (! state.noContextConfirmed) {
//                state.isPlaying = false;
//                FragmentManager fm = getFragmentManager();
//                if (fm.findFragmentByTag("confirm_dialog") == null) {
//                    DialogFragment d = new ConfirmDialog();
//                    d.show(fm, "confirm_dialog");
//                }
//            }
//        }

        loadModels();
        updateViews();
    }

    public void onConfirm(boolean confirm, boolean reopen) {
        if (confirm) {
            if (reopen) {
                DialogFragment d = new ConfirmDialog();
                d.show(getFragmentManager(), "confirm_dialog");
                Toast.makeText(this, R.string.browser_wrong_confirm, Toast.LENGTH_SHORT).show();
            } else {
                state.noContextConfirmed = true;
                state.isPlaying = true;

                videoView.requestFocus();
                videoView.seekToWithoutListener(state.position);
                videoView.startWithoutListener();
            }
        } else {
            finish();
        }
    }

    protected int trackerGetLastPosition() {
        if (mTrackable == null || mTrackingId == null) return 0;
        TrackerFileState last = orm.trackerFileStateDao.findFor(mTrackingId, mTrackable);
        return (last != null && last.position != null) ? last.position : 0;
    }

    protected void trackerSetLastPosition(int position) {
        if (mTrackable == null || mTrackingId == null) return;
        TrackerFileState state = orm.trackerFileStateDao.findOrCreate(mTrackingId, mTrackable);
        state.position = position;
        state.saveWithTimestamps();
    }

    private String buildTitle(String relPath) {
        return relPath;
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        updateState(false, true);
        trackerSetLastPosition(state.position);
        outState.putParcelable("state", state);
    }

    private void loadModels() {
        repoService = new RepoService(getApplicationContext(), mConfig, orm, repoName);
        videoPres = repoService.getFile(relPath);
        if (videoPres == null || videoPres.getFile() == null || (! videoPres.getFile().canRead())) {
            Toast.makeText(this, R.string.browser_no_file, Toast.LENGTH_LONG).show();
            finish();
        }
    }

    private void findViews() {
        videoView = (ObservableVideoView) findViewById(R.id.repo_view_video);
    }

    private void updateViews() {
        File file = videoPres.getFile();
        if (file == null) return;
        videoView.setMediaController(new MediaController(this));
        videoView.setVideoPath("file://" + file.getAbsolutePath());
        videoView.setOnCompletionListener(this);
        videoView.setVideoActionListener(this);
    }

    @Override
    public void onResume() {
        super.onResume();
        logger.debug("onResume");
        videoView.requestFocus();
        videoView.seekToWithoutListener(state.position);
        if (state.isPlaying) {
            videoView.startWithoutListener();
        }
    }

    @Override
    public void onPause() {
        updateState(false, true);
        updateTracker();
        trackerSetLastPosition(state.position);
        videoView.pauseWithoutListener();
        super.onPause();
    }

    @Override
    public void onVideoPause() {
        updateState(true, true);
        updateTracker();
    }

    @Override
    public void onVideoStart() {
        updateState(true, true);
        updateTracker();
    }

    @Override
    public void onVideoSeekTo(int currentTime) {
        updateState(false, true);
        updateTracker();
    }

    @Override
    public void onCompletion(MediaPlayer mp) {
        updateState(true, true);
        updateTracker();
    }

    void updateTracker() {
        if (trackerFile == null) return;

        if (hitBuilder != null) {
            trackerFile.save(hitBuilder.build());
            hitBuilder = null;
        }

        if (state.isPlaying) {
            hitBuilder = new HitFileEvent.Builder();
            hitBuilder.setBeginning(state.position);
        }
    }

    void updateState(boolean isPlaying, boolean position) {
        if (isPlaying) {
            state.isPlaying = videoView.isPlaying();
        }
        if (position) {
            state.position = videoView.getCurrentPosition();
        }
    }

    private static class SaveState implements Parcelable {
        public boolean isPlaying = true;
        public int position = 0;
        public boolean noContextConfirmed = false;

        public SaveState() {
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeByte(isPlaying ? (byte) 1 : (byte) 0);
            dest.writeInt(this.position);
            dest.writeByte(noContextConfirmed ? (byte) 1 : (byte) 0);
        }

        protected SaveState(Parcel in) {
            this.isPlaying = in.readByte() != 0;
            this.position = in.readInt();
            this.noContextConfirmed = in.readByte() != 0;
        }

        public static final Creator<SaveState> CREATOR = new Creator<SaveState>() {
            public SaveState createFromParcel(Parcel source) {
                return new SaveState(source);
            }

            public SaveState[] newArray(int size) {
                return new SaveState[size];
            }
        };
    }

}
