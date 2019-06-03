package com.grw.mobi.events;

public class LoginEvent {
    public enum Status {
        INIT,
        RUNNING,
        SUCCESS,
        LOGIN_ERROR,
        NET_ERROR
    }

    public enum Stage {
        ACCOUNT,
        LOGIN
    }

    public Status status;
    public String reason;
    public Stage stage;

    public LoginEvent() {
        this.status = Status.INIT;
    }

    public LoginEvent(Status status) {
        this.status = status;
    }

    public LoginEvent(Status status, String reason, Stage stage) {
        this.status = status;
        this.reason = reason;
        this.stage = stage;
    }

    public boolean isRunning() {
        return status == Status.RUNNING;
    }

    public boolean isSuccessful() {
        return status == Status.SUCCESS;
    }

    public boolean hasError() {
        return  status == Status.LOGIN_ERROR || status == Status.NET_ERROR;
    }

}
