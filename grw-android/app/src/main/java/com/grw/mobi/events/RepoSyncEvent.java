package com.grw.mobi.events;

public class RepoSyncEvent {

    public enum Status {
        RUNNING,
        SUCCESS,
        NET_ERROR,
        OTHER_ERROR
    }

    public Status status;
    public String progressInfo;

    private long createdAt = 0;

    public RepoSyncEvent(Status status) {
        this.createdAt = System.currentTimeMillis();
        this.status = status;
    }

    public boolean recent() {
        return System.currentTimeMillis() - createdAt < 3 * 1000;
    }

}
