package com.grw.mobi.models;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.grw.mobi.aorm.RepoFileGen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;

public class RepoFile extends RepoFileGen {
    private static final Logger logger = LoggerFactory.getLogger(RepoFile.class);

    public static final String STATE_NEW = "new";
    public static final String STATE_TMP = "tmp";
    public static final String STATE_STAGED = "staged";

    public RepoFile() {
    }

    public RepoFile(@NonNull String repoName, @NonNull String hash, @NonNull Long size, @Nullable String repoPath, @Nullable String localPath) {
        logger.debug("Init new {} {} {}", hash, repoPath, localPath);
        this.repo_name = repoName;
        this.hash = hash;
        this.size = size;
        this.repo_path = repoPath;
        this.local_path = localPath;
        this.repo_item_id = null;
        if (localPath != null) {
            this.state = STATE_TMP;
        } else {
            this.state = STATE_NEW;
        }
    }

    public RepoFile(@NonNull File absTmpDir, @NonNull File absStageDir, @NonNull String repoName, @NonNull String hash,
                    @NonNull Long size, @NonNull String path, @NonNull Integer repoItemId, @Nullable RepoFile sameHash) {

        File stagePath = new File(absStageDir, path);
        if (size > 0) {
            if (sameHash == null) {
                throw new RuntimeException("No content file for " + path);
            }
            logger.debug("Create {} <- {}", path, sameHash.local_path);
            File sameHashFile = sameHash.getAbsPath(absTmpDir, absStageDir);
            RepoUtils.createAndCopy(stagePath, sameHashFile);

        } else {
            logger.debug("Create empty {}", path);
            RepoUtils.createEmpty(stagePath);
        }
        this.repo_name = repoName;
        this.hash = hash;
        this.size = size;
        this.repo_path = path;
        this.local_path = path;
        this.repo_item_id = repoItemId;
        this.state = STATE_STAGED;
    }

    public boolean isNew() {
        return this.state.equals(STATE_NEW);
    }

    public boolean isStaged() {
        return this.state.equals(STATE_STAGED);
    }

    public boolean isLinked() {
        return repo_item_id != null;
    }

    @NonNull
    public File getAbsPath(@NonNull File absTmpDir, @NonNull File absStageDir) {
        return new File(isStaged() ? absStageDir : absTmpDir, local_path);
    }

    public void setContent(@NonNull File absoluteTmpDir, @NonNull File downloadPath, @NonNull String mimeType) {
        File tmpPath = new File(absoluteTmpDir, hash);
        logger.debug("New download {} {}", hash, repo_path, downloadPath);
        if (! downloadPath.renameTo(tmpPath)) {
            throw new RuntimeException("Cannot rename " + downloadPath + " -> " + tmpPath);
        }
        this.local_path = hash;
        this.state = STATE_TMP;
        this.save();
    }

    public void setStaged(@NonNull File absTmpDir, @NonNull File absStageDir, @NonNull String path, @NonNull Integer repoItemId) {
        if (isStaged() && local_path.equals(path)) {
            this.repo_item_id = repoItemId;
            this.save();
            return;
        }

        File oldPath = getAbsPath(absTmpDir, absStageDir);
        File newPath = new File(absStageDir, path);
        logger.debug("Rename file {} -> {}", local_path, path);
        RepoUtils.rename(oldPath, newPath);

        this.repo_path = path;
        this.local_path = path;
        this.repo_item_id = repoItemId;
        this.state = STATE_STAGED;
        this.save();
    }

    public void destroy(@NonNull File absTmpDir, @NonNull File absStageDir, ArrayList<String> linkedPaths) {
        boolean linkedPath = Collections.binarySearch(linkedPaths, local_path) >= 0;
        logger.debug("RepoFile destroy {} {}", linkedPath, local_path);
        if (!linkedPath) {
            deleteFile(absTmpDir, absStageDir);
        }
        destroy();
    }

    private void deleteFile(@NonNull File absTmpDir, @NonNull File absStageDir) {
        File absPath = getAbsPath(absTmpDir, absStageDir);
        if (absPath.exists()) {
            if (!absPath.delete()) {
                throw new RuntimeException("Cannot delete file " + local_path);
            }
        } else {
            logger.warn("RepoFile delete {} - doesn't exist", local_path);
        }
    }

    public void setNewRepoPath(String repoPath) {
        if (repoPath != null && this.repo_path != null && this.repo_path.equals(repoPath)) return;
        this.repo_path = repoPath;
        save();
    }

}
