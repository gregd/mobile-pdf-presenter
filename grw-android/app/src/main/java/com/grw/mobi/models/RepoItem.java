package com.grw.mobi.models;

import android.content.Context;
import android.support.annotation.NonNull;

import com.grw.mobi.aorm.RepoItemGen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.ArrayList;

public class RepoItem extends RepoItemGen {
    private static final Logger logger = LoggerFactory.getLogger(RepoItem.class);

    public RepoItem() {}

    public RepoItem(@NonNull Integer repoRevId, @NonNull String path, @NonNull String type, @NonNull String hash, @NonNull Long size) {
        this.repo_revision_id = repoRevId;
        this.path = path;
        this.type = type;
        this.hash = hash;
        this.size = size;
    }

    public boolean downloadable() {
        return this.size > 0;
    }

    public boolean linkFile(Context context, @NonNull String repo_name, File absTmpDir, File absStageDir) {
        ArrayList<RepoFile> withHash = session.repoFileDao.getWithHash(repo_name, hash).execute();

        // try to link existing file and rename if needed
        for (RepoFile file : withHash) {
            if (file.isLinked()) continue;
            file.setStaged(absTmpDir, absStageDir, path, mid);
            return true;
        }

        // create empty file or copy existing
        RepoFile sameHash = withHash.size() > 0 ? withHash.get(0) : null;

        if (size > 0 && sameHash == null) {
            logger.warn("No file for {} {}", path, size);
            return false;
        }

        // there is no need to check available space for each small file
        if (size >= RepoUtils.ONE_MEGABYTE) {
            RepoUtils.StorageStats stats = RepoUtils.internalStorageStats(context);
            if (size + RepoUtils.LEAVE_BYTES > stats.availableBytes) {
                logger.warn("No space to copy {} {}", path, size);
                return false;
            }
        }

        RepoFile file = new RepoFile(absTmpDir, absStageDir, repo_name, hash, size, path, mid, sameHash);
        file.setSession(session);
        file.save();
        return true;
    }

}
