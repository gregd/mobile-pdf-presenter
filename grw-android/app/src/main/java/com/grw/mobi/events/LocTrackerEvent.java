package com.grw.mobi.events;

public class LocTrackerEvent {
    public enum Status {
        RUNNING,
        IDLE
    }

    public Status status;

    public LocTrackerEvent(Status status) {
        this.status = status;
    }

}
