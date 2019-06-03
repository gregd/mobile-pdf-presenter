package com.grw.mobi.trackers;

import android.os.SystemClock;

import java.util.Date;

public class HitFileEvent {
    public static final long DURATION_THRESHOLD = 1000;

    public Date start;
    public Integer trackingId;
    public Integer page;
    public Integer beginning;
    public Long duration;
    public String trackableType;
    public String trackableUuid;
    public Integer trackableId;

    public boolean toSave() {
        return duration != null && duration > DURATION_THRESHOLD;
    }

    public static class Builder {
        private long startAt = SystemClock.elapsedRealtime();
        private Date start = new Date();
        private Integer trackingId;
        private Integer page;
        private Integer beginning;
        private Long duration;
        private String trackableType;
        private String trackableUuid;
        private Integer trackableId;

        public Builder setStart(Date start) {
            this.start = start;
            return this;
        }

        public Builder setTrackingId(Integer trackingId) {
            this.trackingId = trackingId;
            return this;
        }

        public Builder setPage(Integer page) {
            this.page = page;
            return this;
        }

        public Builder setBeginning(Integer beginning) {
            this.beginning = beginning;
            return this;
        }

        public Builder setDuration(Long duration) {
            this.duration = duration;
            return this;
        }

        public Builder setTrackable(String type, String uuid, Integer id) {
            trackableType = type;
            trackableUuid = uuid;
            trackableId = id;
            return this;
        }

        public HitFileEvent build() {
            HitFileEvent ob = new HitFileEvent();
            if (duration == null) {
                duration = SystemClock.elapsedRealtime() - startAt;
            }
            ob.start = start;
            ob.trackingId = trackingId;
            ob.page = page;
            ob.beginning = beginning;
            ob.duration = duration;
            ob.trackableType = trackableType;
            ob.trackableUuid = trackableUuid;
            ob.trackableId = trackableId;
            return ob;
        }
    }
}
