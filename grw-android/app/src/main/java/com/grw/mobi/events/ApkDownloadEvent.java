package com.grw.mobi.events;

import android.net.Uri;

public class ApkDownloadEvent {
    public enum Status {
        RUNNING,
        SUCCESS,
        NET_ERROR
    }

    public Status status;
    public Uri uri;

    public ApkDownloadEvent(Status status) {
        this.status = status;
    }

    public ApkDownloadEvent(Status status, Uri uri) {
        this.status = status;
        this.uri = uri;
    }

}
