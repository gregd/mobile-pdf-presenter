package com.grw.mobi.trackers;

import java.util.Date;

public class HitAppEvent {
    public Date start;
    public String screen;
    public String category;
    public String action;
    public String label;
    public Long value;
    public Integer personId;
    public Integer instId;

    public static class Builder {
        private Date start;
        private String screen;
        private String category;
        private String action;
        private String label;
        private Long value;
        private Integer personId;
        private Integer instId;

        public Builder setStart(Date start) {
            this.start = start;
            return this;
        }

        public Builder setScreen(String screen) {
            this.screen = screen;
            return this;
        }

        public Builder setCategory(String category) {
            this.category = category;
            return this;
        }

        public Builder setAction(String action) {
            this.action = action;
            return this;
        }

        public Builder setLabel(String label) {
            this.label = label;
            return this;
        }

        public Builder setValue(Long value) {
            this.value = value;
            return this;
        }

        public Builder setPersonId(Integer personId) {
            this.personId = personId;
            return this;
        }

        public Builder setInstId(Integer instId) {
            this.instId = instId;
            return this;
        }

        public HitAppEvent build() {
            HitAppEvent ob = new HitAppEvent();
            ob.start = start;
            ob.screen = screen;
            ob.category = category;
            ob.action = action;
            ob.value = value;
            ob.label = label;
            ob.personId = personId;
            ob.instId = instId;
            return  ob;
        }
    }

}
