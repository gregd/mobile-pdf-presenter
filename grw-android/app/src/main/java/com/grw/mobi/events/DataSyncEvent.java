package com.grw.mobi.events;

public class DataSyncEvent {
    public enum Status {
        RUNNING,
        SUCCESS,
        UPGRADE_ERROR,
        NET_ERROR,
        OTHER_ERROR
    }

    public Status status;

    public int totalRecords = 0;
    public int records = 0;
    public int stageRecords = 0;
    public String stage;

    private long createdAt = 0;

    public DataSyncEvent(Status status) {
        this.createdAt = System.currentTimeMillis();
        this.status = status;
    }

    public boolean recent() {
        return System.currentTimeMillis() - createdAt < 3 * 1000;
    }

}
