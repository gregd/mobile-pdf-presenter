package com.grw.mobi.services;

import android.content.Context;
import android.os.SystemClock;
import android.support.annotation.Nullable;
import android.support.v4.util.Pair;

import com.grw.mobi.Config;
import com.grw.mobi.R;
import com.grw.mobi.aorm.OrmSession;
import com.grw.mobi.events.RepoSyncEvent;
import com.grw.mobi.models.RepoFile;
import com.grw.mobi.models.RepoItem;
import com.grw.mobi.models.RepoRevision;
import com.grw.mobi.models.RepoUtils;
import com.grw.mobi.presenters.RepoFilePresenter;
import com.grw.mobi.util.DateUtils;
import com.grw.mobi.util.NetUtils;
import com.grw.mobi.util.UIUtils;

import org.acra.ACRA;
import org.greenrobot.eventbus.EventBus;
import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import okhttp3.FormBody;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okio.BufferedSink;
import okio.Okio;

public class RepoService extends StatelessService {
    private static final Logger logger = LoggerFactory.getLogger(RepoService.class);
    private static final String TMP_PREFIX = "download";
    private static final int PROGRESS_SIZE_LIMIT = 100 * 1024;

    public static final String REPO_MAIN = "main";

    public enum SyncState {
        Ok,
        NetError,
        OtherError,
        InternalError
    }

    public static class Result {
        public SyncState state = SyncState.Ok;
        public boolean newFiles = false;

        public boolean stop() {
            return state != SyncState.Ok;
        }
    }

    public static boolean isActive() {
        return sStartAt != 0;
    }

    static long sStartAt = 0;
    Context context;
    Config config;
    OrmSession session;
    OkHttpClient client;
    String repoName;

    public RepoService(Context context, Config config, OrmSession orm, String repoName) {
        this.context = context;
        this.config = config;
        this.session = orm;
        this.repoName = repoName;
    }

    @Nullable
    public List<RepoFilePresenter> getDir(String relPath) {
        RepoRevision rev = session.repoRevisionDao.getCurrent(repoName);
        if (rev == null) return null;
        return RepoFilePresenter.getDir(context, rev, relPath);
    }

    @Nullable
    public RepoFilePresenter getFile(String relPath) {
        RepoRevision rev = session.repoRevisionDao.getCurrent(repoName);
        if (rev == null) return null;
        return RepoFilePresenter.getFile(context, rev, relPath);
    }

    public Result sync() {
        sStartAt = SystemClock.elapsedRealtime();
        Result result = new Result();
        try {
            loadIndex(result);
            if (result.stop()) return result;

            checkAndRecoverFiles();

            if (downloadContent() > 0) {
                result.newFiles = true;
            }
            if (switchToLatest() > 0) {
                result.newFiles = true;
            }

            long now = SystemClock.elapsedRealtime();
            long duration = now - sStartAt;
            logger.debug("duration {} {}", duration / android.text.format.DateUtils.SECOND_IN_MILLIS, result.newFiles);
            return result;
        }
        catch (Exception ex) {
            if (Config.DEBUG) {
                throw new RuntimeException("repo service sync exception", ex);
            }
            if (NetUtils.isNetworkException(ex)) {
                result.state = SyncState.NetError;
            } else {
                result.state = SyncState.InternalError;
                ACRA.getErrorReporter().handleSilentException(ex);
            }
            return result;
        }
        finally {
            sStartAt = 0;
        }
    }

    private void loadIndex(Result result) {
        try {
            logger.debug("loadIndex");
            if (client == null) {
                client = NetUtils.getClient(context);
            }

            final FormBody.Builder params = new FormBody.Builder();
            NetUtils.addLoginParams(context, params, config);

            params.add("repo[name]", repoName);

            RepoRevision latestRev = session.repoRevisionDao.getLatest(repoName);
            params.add("repo[rev]", latestRev != null ? latestRev.hash : "");

            RepoRevision current = session.repoRevisionDao.getCurrent(repoName);
            if (current == null) {
                params.add("current[rev]", "");

            } else {
                params.add("current[rev]", current.hash);
                if (current.missing_count > 0) {
                    Pair<Integer, Integer> pair = current.toDownloadStats();
                    params.add("current[missing_count]", String.valueOf(pair.first));
                    params.add("current[missing_size]", String.valueOf(pair.second));
                }
                if (current.unlinked_count > 0) {
                    params.add("current[unlinked_count]", String.valueOf(current.unlinked_count));
                }
            }

            RepoUtils.StorageStats stats;
            params.add("stats[total_mem]", String.valueOf(RepoUtils.totalMem(context)));
            stats = RepoUtils.internalStorageStats(context);
            params.add("stats[internal_available_bytes]", String.valueOf(stats.availableBytes));
            params.add("stats[internal_total_bytes]", String.valueOf(stats.totalBytes));
            stats = RepoUtils.externalStorageStats(context);
            params.add("stats[external_available_bytes]", String.valueOf(stats.availableBytes));
            params.add("stats[external_total_bytes]", String.valueOf(stats.totalBytes));

            final Request request = new Request.Builder()
                    .url(config.getRepoIndexUri())
                    .post(params.build())
                    .build();
            final Response response = client.newCall(request).execute();
            if (!response.isSuccessful()) throw new NetUtils.NetException(response.toString());

            final JSONObject jsonRes = new JSONObject(response.body().string());

            final String srvResult = jsonRes.getString("result");
            switch (srvResult) {
                case "success":
                    break;

                case "error":
                case "not_logged":
                    logger.debug("loadIndex srvResult {}", srvResult);
                    result.state = SyncState.OtherError;
                    return;

                default:
                    throw new RuntimeException("Server returned " + srvResult);
            }

            if (jsonRes.has("repo_reset")) {
                logger.debug("repo_reset");
                session.mSQLite.beginTransaction();
                try {
                    removeAllFiles(context);
                    session.repoRevisionDao.resetRepoTables();
                    session.mSQLite.setTransactionSuccessful();
                } finally {
                    session.mSQLite.endTransaction();
                }
            }

            if (jsonRes.has("repo_recover")) {
                logger.debug("repo_recover");
                session.mSQLite.beginTransaction();
                try {
                    session.repoRevisionDao.resetRepoTables();
                    recoverAllFiles();
                    session.mSQLite.setTransactionSuccessful();
                } finally {
                    session.mSQLite.endTransaction();
                }
            }

            String srvRepoName = jsonRes.getString("repo_name");
            if (!repoName.equals(srvRepoName)) {
                throw new RuntimeException("repo_name mismatch " + repoName + " vs " + srvRepoName);
            }

            String state = jsonRes.getString("state");
            if (state.equals("current")) {
                logger.debug("loadIndex current {} {}", repoName, jsonRes.getString("hash"));
                return;
            }

            String srvHash = jsonRes.getString("hash");
            RepoRevision hashRev = session.repoRevisionDao.getWithHash(repoName, srvHash);
            if (hashRev != null) {
                logger.warn("loadIndex revision already present {} {}", repoName, srvHash);
                return;
            }

            // save new revision and items
            RepoRevision newRev;
            session.mSQLite.beginTransaction();
            try {
                newRev = new RepoRevision(
                        repoName,
                        srvHash,
                        DateUtils.sIso8601.parse(jsonRes.getString("modified_at")),
                        jsonRes.getInt("items_count"));
                newRev.setSession(session);
                newRev.save();
                logger.debug("loadIndex new rev {} {} {}", repoName, newRev.hash, newRev.items_count);

                JSONArray itemsArray = jsonRes.getJSONArray("items");
                int count = itemsArray.length();
                if (newRev.items_count != count) {
                    throw new RuntimeException("repo items_count mismatch " + newRev.items_count + " vs " + count);
                }

                for (int i = 0; i < count; i++) {
                    JSONObject ob = itemsArray.getJSONObject(i);
                    RepoItem item = new RepoItem(
                            newRev.mid,
                            ob.getString("path"),
                            ob.getString("type"),
                            ob.getString("hash"),
                            ob.getLong("size"));
                    item.setSession(session);
                    item.save();
                }
                session.mSQLite.setTransactionSuccessful();
            } finally {
                session.mSQLite.endTransaction();
            }

            logger.debug("loadIndex newRev {} {} {}", newRev.repo_name, newRev.hash, newRev.items_count);

        } catch (IOException ex) {
            throw new NetUtils.NetException("Repo index load error", ex);

        } catch (Exception ex) {
            throw new RuntimeException("Repo index parsing error", ex);
        }
    }

    private void checkAndRecoverFiles() {
        int count = session.repoFileDao.countWhere("1 = 1");
        if (count > 0) return;

        logger.debug("No repo files, try to recover existing files");
        recoverAllFiles();
    }

    private int downloadContent() {
        try {
            RepoRevision rev = session.repoRevisionDao.getLatest(repoName);
            if (rev == null || (! rev.shouldDownload())) return 0;
            logger.debug("downloadContent {} {} {} {}", rev.repo_name, rev.hash, rev.state, rev.missing_count);

            rev.addMissingContent();

            ArrayList<RepoFile> toDownload = rev.toDownload();
            if (toDownload.size() == 0) {
                logger.debug("downloadContent no missing");
                return 0;
            }

            if (client == null) {
                client = NetUtils.getClient(context);
            }

            File absTmpDir = rev.absTmpDir(context);
            rev.missing_count = 0;
            int downloadedCount = 0;

            for (RepoFile file : toDownload) {
                RepoUtils.StorageStats stats = RepoUtils.internalStorageStats(context);
                if (file.size + RepoUtils.LEAVE_BYTES > stats.availableBytes) {
                    if (rev.notification_count == 0) {
                        UIUtils.addNoSpaceNotification(context);
                        rev.notification_count += 1;
                    }
                    rev.missing_count += 1;
                    continue;
                }

                final FormBody.Builder params = new FormBody.Builder();
                NetUtils.addLoginParams(context, params, config);

                params.add("repo[name]", rev.repo_name);
                params.add("repo[rev]", rev.hash);
                params.add("repo[path]", file.repo_path);

                if (file.size > PROGRESS_SIZE_LIMIT) {
                    RepoSyncEvent e = new RepoSyncEvent(RepoSyncEvent.Status.RUNNING);
                    String fn = new File(file.repo_path).getName();
                    e.progressInfo = String.format(context.getString(R.string.browser_downloading), fn);
                    EventBus.getDefault().postSticky(e);
                }

                final Request request = new Request.Builder()
                        .url(config.getRepoDownloadUri())
                        .post(params.build())
                        .build();
                final Response response = client.newCall(request).execute();
                if (!response.isSuccessful()) throw new NetUtils.NetException(response.toString());

                long contentLength = response.body().contentLength();
                if (contentLength == -1) {
                    throw new RuntimeException("Repo download file response has no content length");
                }
                if (contentLength != file.size) {
                    throw new RuntimeException("Repo download file content length mismatch");
                }
                MediaType contentType = response.body().contentType();
                if (contentType == null) {
                    throw new RuntimeException("Repo download file no content type");
                }

                File downloadPath = File.createTempFile(TMP_PREFIX, null, absTmpDir);
                final BufferedSink sink = Okio.buffer(Okio.sink(downloadPath));
                sink.writeAll(response.body().source());
                sink.close();

                long downloadLength = downloadPath.length();
                if (downloadLength != file.size) {
                    throw new NetUtils.NetException("Repo download error");
                }

                file.setContent(absTmpDir, downloadPath, contentType.toString());
                downloadedCount += 1;
            }

            if (rev.missing_count > 0) {
                logger.debug("downloadContent cannot download {} files", rev.missing_count);
            }
            rev.save();
            return downloadedCount;

        }
        catch (IOException ex) {
            throw new NetUtils.NetException("Repo download file error", ex);
        }
    }

    private int switchToLatest() {
        RepoRevision rev = session.repoRevisionDao.getLatest(repoName);
        if (rev == null || (! rev.shouldLinkFiles())) return 0;
        logger.debug("switchToLatest {} {} {} {}", rev.repo_name, rev.hash, rev.state, rev.unlinked_count);

        // TODO return number of new directories and new files copied from others
        rev.switchTo(context);
        return 0;
    }

    public static void initDirs(Context context) throws IOException {
        File root = RepoRevision.getRootDir(context);
        if (! root.isDirectory()) {
            if (! root.mkdirs()) throw new RuntimeException("Cannot create repos dir");
            logger.debug("create repos dir");
        }
        File nomedia = new File(root, ".nomedia");
        if ((! nomedia.exists()) && nomedia.createNewFile()) {
            logger.debug("repos nomedia file created");
        }
        File stageDir = RepoRevision.absStageDir(context, REPO_MAIN);
        if (! stageDir.isDirectory()) {
            if (! stageDir.mkdirs()) throw new RuntimeException("Cannot crate main stage dir");
            logger.debug("repo main stage dir created");
        }
        File tmpDir = RepoRevision.absTmpDir(context, REPO_MAIN);
        if (! tmpDir.isDirectory()) {
            if (! tmpDir.mkdirs())  throw new RuntimeException("Cannot crate main tmp dir");
            logger.debug("repo main tmp dir created");
        }
    }

    public static void removeAllFiles(Context context) {
        logger.debug("removeAllFiles");
        try {
            RepoUtils.deleteRecursive(RepoRevision.getRootDir(context));
            initDirs(context);
        } catch (IOException ex) {
            throw new RuntimeException("Cannot remove or initialize dirs", ex);
        }
    }

    public void recoverAllFiles() {
        File absTmpDir = RepoRevision.absTmpDir(context, REPO_MAIN);
        File absStageDir = RepoRevision.absStageDir(context, REPO_MAIN);
        recoverTmpFiles(absTmpDir);
        recoverStagedFiles(absStageDir, absTmpDir);
        RepoUtils.deleteEmptyDirs(absStageDir);
        logger.debug("Repo files recovered");
    }

    private void recoverTmpFiles(File tmpDir) {
        for (File file : tmpDir.listFiles()) {
            if (file.isDirectory()) {
                logger.warn("tmp dir should not contain dirs {}", file);
                continue;
            }

            long size = file.length();

            if (size == 0 || file.getName().startsWith(TMP_PREFIX)) {
                logger.debug("delete empty or tmp file {}", file);
                if (! file.delete()) {
                    throw new RuntimeException("Cannot delete empty file " + file);
                }
                continue;
            }

            String gitHash = RepoUtils.computeGitHash(file);
            if (! gitHash.equals(file.getName())) {
                logger.warn("Git hash mismatch " + file + " != " + gitHash);
                if (! file.delete()) {
                    throw new RuntimeException("Cannot delete empty file " + file);
                }
                continue;
            }
            RepoFile rf = new RepoFile(REPO_MAIN, gitHash, size, null, gitHash);
            rf.setSession(session);
            rf.save();
        }
    }

    private void recoverStagedFiles(File dir, File tmpDir) {
        for (File file : dir.listFiles()) {
            if (file.isDirectory()) {
                recoverStagedFiles(file, tmpDir);
                continue;
            }

            long size = file.length();
            if (size == 0) {
                logger.debug("delete empty file {}", file);
                if (! file.delete()) {
                    throw new RuntimeException("Cannot delete empty file " + file);
                }
                continue;
            }

            String gitHash = RepoUtils.computeGitHash(file);
            File tmpNew = new File(tmpDir, gitHash);

            if (tmpNew.exists()) {
                logger.debug("delete existing {} -> {}", file, tmpNew);
                if (file.delete()) {
                    throw new RuntimeException("Cannot delete file " + file);
                }

            } else {
                logger.debug("recover file {} -> {}", file, tmpNew);
                if (! file.renameTo(tmpNew)) {
                    throw new RuntimeException("Cannot rename file " + file + " -> " + tmpNew);
                }
                RepoFile rf = new RepoFile(REPO_MAIN, gitHash, size, null, gitHash);
                rf.setSession(session);
                rf.save();
            }
        }
    }

}
