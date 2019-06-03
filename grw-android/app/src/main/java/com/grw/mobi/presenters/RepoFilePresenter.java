package com.grw.mobi.presenters;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.google.gson.Gson;
import com.grw.mobi.R;
import com.grw.mobi.models.RepoRevision;
import com.grw.mobi.models.RepoUtils;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class RepoFilePresenter {
    private static final String GIT_KEEP = ".gitkeep";
    private static final String META_PREFIX = "__";
    private static final List<String> CoverImgNames = Arrays.asList("cover.png", "cover.jpeg", "cover.jpg");
    private static final String JsonFileName = "meta-info.json";
    private static final String MIME_TYPE_HTML = "text/html";
    private static final String MIME_TYPE_VIDEO = "video/mp4";
    private static final String MIME_TYPE_PDF = "application/pdf";

    public static class MetaInfo {
        public Integer tracking_id;
        public String mime_type;
        public String title;
        public String description;
        public Integer pages;
        public Integer seconds;
        public MetaInfo() {}
        public boolean isHtml() {
            return mime_type != null && mime_type.equals(MIME_TYPE_HTML);
        }
        public boolean isVideo() {
            return mime_type != null && mime_type.equals(MIME_TYPE_VIDEO);
        }
        public boolean isPdf() {
            return mime_type != null && mime_type.equals(MIME_TYPE_PDF);
        }
    }

    public boolean isDir;
    public String name;
    public File cover;
    public int iconResId;
    public MetaInfo info;

    // data taken from TrackerFileState
    public Integer stateProgress;

    private String repoName;
    private String relPath;
    private File file;

    private RepoFilePresenter(@NonNull String repoName, @Nullable String relPath, @NonNull File file) {
        this.repoName = repoName;
        this.relPath = relPath;
        this.file = file;
        this.isDir = file.isDirectory();
        this.name = file.getName();
        File metaDir = metaDirFor(file);
        if (metaDir != null) {
            info = getMetaInfoFor(metaDir);
            cover = getCoverFor(metaDir);
        }
        if (cover == null) {
            if (isDir) {
                iconResId = R.drawable.ic_folder_outline_64dp;
            } else {
                iconResId = R.drawable.ic_image_broken_64dp;
            }
        }
    }

    @NonNull
    public String getTitle() {
        // kiedy użyć title z info

        // remove file extension
        int i = name.lastIndexOf('.');
        return i > 0 ? name.substring(0, i) : name;
    }

    @Nullable
    public String getDescription(Context context) {
        if (info == null) return null;
        if (info.pages != null) {
            return String.format(context.getString(R.string.browser_desc_pages), (int) info.pages);
        }
        if (info.seconds != null) {
            return String.format(context.getString(R.string.browser_desc_seconds), (int) info.seconds);
        }
        return info.description;
    }

    @NonNull
    public String getRepoName() {
        return repoName;
    }

    @Nullable
    public String getRelPath() {
        return relPath;
    }

    @Nullable
    public File getFile() {
        return file;
    }

    @Nullable
    public Integer getTrackingId() {
        return info != null ? info.tracking_id : null;
    }

    public boolean isHtml() {
        return info != null && info.isHtml();
    }

    public boolean isVideo() {
        return info != null && info.isVideo();
    }

    public boolean isPdf() {
        return info != null && info.isPdf();
    }

    public static @Nullable RepoFilePresenter getFile(@NonNull Context context, @NonNull RepoRevision rev, @NonNull String relPath) {
        File file = rev.fileFor(context, relPath);
        if (! file.exists()) {
            return null;
        }
        return new RepoFilePresenter(
                rev.repo_name,
                relPath,
                file);
    }

    public static List<RepoFilePresenter> getDir(@NonNull Context context, @NonNull RepoRevision rev, @Nullable String relPath) {
        ArrayList<RepoFilePresenter> result = new ArrayList<>();
        File dir;

        if (relPath == null) {
            dir = rev.absStageDir(context);
        } else {
            dir = rev.fileFor(context, relPath);
        }

        File[] files = dir.listFiles();
        if (files == null) {
            throw new RuntimeException("Not a directory " + dir);
        }

        RepoUtils.sortByDirAndName(files);

        for (File file : files) {
            String name = file.getName();
            if (! isUserVisible(name)) continue;
            result.add(new RepoFilePresenter(
                    rev.repo_name,
                    rev.relPathFor(context, file),
                    file));
        }

        return result;
    }

    private static boolean isUserVisible(@NonNull String fileName) {
        if (GIT_KEEP.equals(fileName)) return false;
        if (fileName.startsWith(META_PREFIX)) return false;
        return true;
    }

    private static @Nullable File metaDirFor(@NonNull File file) {
        File meta = new File(file.getParent(), META_PREFIX + file.getName());
        if (meta.exists() && meta.isDirectory()) {
            return meta;
        } else {
            return null;
        }
    }

    private static @Nullable File getCoverFor(@NonNull File metaDir) {
        for (String imgName : CoverImgNames) {
            File cover = new File(metaDir, imgName);
            if (cover.exists()) return cover;
        }
        return null;
    }

    private static @Nullable MetaInfo getMetaInfoFor(@NonNull File metaDir) {
        File jsonFile = new File(metaDir, JsonFileName);
        if (! jsonFile.exists()) return null;
        try {
            Gson gson = new Gson();
            return gson.fromJson(new FileReader(jsonFile), MetaInfo.class);

        } catch (IOException ex) {
            throw new RuntimeException("JSON parse error", ex);
        }
    }

}
