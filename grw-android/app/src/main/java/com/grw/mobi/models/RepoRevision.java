package com.grw.mobi.models;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.util.Pair;

import com.grw.mobi.Config;
import com.grw.mobi.aorm.RepoRevisionGen;

import org.acra.ACRA;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;

public class RepoRevision extends RepoRevisionGen {
    private static final Logger logger = LoggerFactory.getLogger(RepoRevision.class);

    public static final String STATE_NEW     = "new";
    public static final String STATE_CURRENT = "current";
    public static final String STATE_OLD     = "old";

    public RepoRevision() {}

    public RepoRevision(@NonNull String repoName, @NonNull String hash, @NonNull Date modifiedAt, @NonNull Integer itemsCount) {
        this.repo_name = repoName;
        this.hash = hash;
        this.modified_at = modifiedAt;
        this.items_count = itemsCount;
        this.state = STATE_NEW;
        this.missing_count = 0;
        this.unlinked_count = 0;
        this.notification_count = 0;
    }

    public boolean isNew() {
        return STATE_NEW.equals(this.state);
    }

    public boolean isCurrent() {
        return STATE_CURRENT.equals(this.state);
    }

    public boolean isOld() {
        return STATE_OLD.equals(this.state);
    }

    public boolean shouldDownload() {
        return isNew() || (isCurrent() && missing_count > 0);
    }

    public boolean shouldLinkFiles() {
        return isNew() || (isCurrent() && unlinked_count > 0);
    }

    @NonNull
    public File absTmpDir(Context context) {
        return new File(getRootDir(context), "tmp_" + repo_name);
    }

    @NonNull
    public static File absTmpDir(Context context, @NonNull String repoName) {
        return new File(getRootDir(context), "tmp_" + repoName);
    }

    // WebView can only load files from cache, sdcard directories
    @NonNull
    public File absStageDir(Context context) {
        return new File(getRootDir(context), "staged_" + repo_name);
    }

    @NonNull
    public static File absStageDir(Context context, @NonNull String repoName) {
        return new File(getRootDir(context), "staged_" + repoName);
    }

    @NonNull
    public static File getRootDir(Context context) {
        return context.getDir("repos", Context.MODE_PRIVATE);
    }

    @NonNull
    public File fileFor(Context context, @NonNull String relPath) {
        return new File(absStageDir(context), relPath);
    }

    @Nullable
    public String relPathFor(Context context, @NonNull File file) {
        String root = absStageDir(context).getAbsolutePath();
        String s = file.getAbsolutePath();
        if (! s.startsWith(root)) {
            throw new RuntimeException("Repo file " + s + " not in repo dir " + root);
        }
        if (s.length() == root.length()) {
            return null;
        }
        return s.substring(root.length());
    }

    public void addMissingContent() {
        session.repoFileDao.resetRepoPathsForNew();

        for (RepoItem item : items()) {
            if (! item.downloadable()) {
                continue;
            }

            ArrayList<RepoFile> list = session.repoFileDao.getWithHash(repo_name, item.hash).execute();
            if (list.size() > 0) {
                for (RepoFile file : list) {
                    if (file.isNew()) {
                        file.setNewRepoPath(item.path);
                    }
                }
                continue;
            }

            RepoFile file = new RepoFile(repo_name, item.hash, item.size, item.path, null);
            file.setSession(session);
            file.save();
        }

        session.repoFileDao.deleteUnneededNew();
    }

    public ArrayList<RepoFile> toDownload() {
        return session.repoFileDao.toDownload(repo_name, RepoFileDao.SortBy.Size).execute();
    }

    public Pair<Integer, Integer> toDownloadStats() {
        ArrayList<RepoFile> list = toDownload();
        int totalSize = 0;
        for (RepoFile file : list) {
            totalSize += file.size;
        }
        return new Pair<>(list.size(), totalSize);
    }

    public void switchTo(Context context) {
        File absTmpDir = absTmpDir(context);
        File absStageDir = absStageDir(context);

        session.mSQLite.beginTransaction();
        try {
            session.repoFileDao.resetLinks();
            unlinked_count = 0;

            for (RepoItem item : items()) {
                if (! item.linkFile(context, repo_name, absTmpDir, absStageDir)) {
                    unlinked_count += 1;
                }
            }

            ArrayList<String> linkedPaths = session.repoFileDao.linkedLocalPaths(repo_name);
            Collections.sort(linkedPaths);

            ArrayList<RepoFile> toDelete = session.repoFileDao.withoutLink(repo_name).execute();
            for (RepoFile file : toDelete) {
                file.destroy(absTmpDir, absStageDir, linkedPaths);
            }
            RepoUtils.deleteEmptyDirs(absStageDir);

            RepoRevision old = dao().getCurrent(repo_name);
            if (old != null && old.mid != this.mid) {
                old.state = STATE_OLD;
                old.save();
            }

            state = STATE_CURRENT;
            save();
            logger.debug("Set rev current {} {} {}", repo_name, hash, unlinked_count);

            session.mSQLite.setTransactionSuccessful();

        } catch (Exception ex) {
            if (Config.DEBUG) {
                throw ex;
            }
            ACRA.getErrorReporter().handleSilentException(ex);

        } finally {
            session.mSQLite.endTransaction();
        }
    }

}
