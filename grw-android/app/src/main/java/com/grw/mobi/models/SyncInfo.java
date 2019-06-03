package com.grw.mobi.models;

import com.grw.mobi.aorm.SyncInfoGen;
import com.grw.mobi.util.Utils;

public class SyncInfo extends SyncInfoGen {

    public SyncInfo() {}

    public boolean isDbEmpty() {
        return last_load_at == null;
    }

    public boolean shouldReload(Integer userId, Integer uaId, String company) {
        if (userId == null || uaId == null || Utils.isBlank(company)) return true;

        return (! userId.equals(this.data_owner_id)) ||
                (! uaId.equals(this.data_assignment_id)) ||
                (! company.equals(this.data_company));
    }

}
