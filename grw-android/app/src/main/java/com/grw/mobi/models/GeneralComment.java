package com.grw.mobi.models;

import com.grw.mobi.aorm.GeneralCommentGen;
import com.grw.mobi.aorm.OrmModel;

public class GeneralComment extends GeneralCommentGen {

    public GeneralComment() {}

    public GeneralComment(Integer userRoleId, String category, OrmModel model) {
        initLocal();
        this.user_role_id = userRoleId;
        this.category = category;
        this.commentable_id = model.mid;
        this.commentable_uuid = model.uuid;
        this.commentable_type = model.canonicalModel();
    }

}
