package com.grw.mobi.models;

import com.grw.mobi.aorm.OrmModel;
import com.grw.mobi.aorm.TrackerFileStateGen;
import com.grw.mobi.util.Utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

public class TrackerFileState extends TrackerFileStateGen {
    private static final Logger logger = LoggerFactory.getLogger(TrackerFileState.class);

    public TrackerFileState() {}

    public TrackerFileState(Integer trackingId, OrmModel trackable) {
        initLocal();
        this.tracking_id = trackingId;
        this.trackable_type = trackable.canonicalModel();
        this.trackable_uuid = trackable.uuid;
        this.trackable_id = trackable.mid;
    }

    public boolean hasReadPages() {
        return ! Utils.isBlank(extras);
    }

    public List<Integer> readPages() {
        ArrayList<Integer> res = new ArrayList<>();
        try {
            String[] sections = extras.split("\\|");
            for (String s : sections) {
                Integer current;
                Integer count = 0;

                if (s.contains(",")) {
                    String[] arr = s.split(",");
                    if (arr.length != 2) continue;

                    current = Integer.valueOf(arr[0]);
                    count = Integer.valueOf(arr[1]);

                } else {
                    current = Integer.valueOf(s);
                }
                if (current == null || count == null) continue;

                for (int i = current; i <= current + count; i++) {
                    res.add(i);
                }
            }
        } catch (NumberFormatException ex) {
            logger.warn("cannot parse extras: {}, {}", extras, ex);
        }
        return res;
    }

}
