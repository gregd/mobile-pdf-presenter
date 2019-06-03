package com.grw.mobi.util;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.VideoView;

public class ObservableVideoView extends VideoView {
    private VideoActionListener mListener;

    public interface VideoActionListener {
        void onVideoPause();
        void onVideoStart();
        void onVideoSeekTo(int currentTime);
    }

    public void setVideoActionListener(VideoActionListener listener) {
        mListener = listener;
    }

    public void pauseWithoutListener() {
        super.pause();
    }

    @Override
    public void pause() {
        super.pause();
        if (mListener != null) {
            mListener.onVideoPause();
        }
    }

    public void startWithoutListener() {
        super.start();
    }

    @Override
    public void start() {
        super.start();
        if (mListener != null) {
            mListener.onVideoStart();
        }
    }

    public void seekToWithoutListener(int msec) {
        super.seekTo(msec);
    }

    @Override
    public void seekTo(int msec) {
        super.seekTo(msec);
        if (mListener != null) {
            mListener.onVideoSeekTo(msec);
        }
    }

    public ObservableVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ObservableVideoView(Context context) {
        super(context);
    }

    public ObservableVideoView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

}
