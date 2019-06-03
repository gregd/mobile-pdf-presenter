package com.grw.mobi.models;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Environment;
import android.os.StatFs;
import android.support.annotation.NonNull;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Formatter;

public class RepoUtils {
    private static final Logger logger = LoggerFactory.getLogger(RepoUtils.class);

    public static final long LEAVE_BYTES = 10 * 1024 * 1024;     // 10 MB
    public static final int ONE_MEGABYTE = 1024 * 1024;

    public static void sortByDirAndName(File[] files) {
        Arrays.sort(files, new Comparator<File>() {
            public int compare(File f1, File f2) {
                String n1, n2;

                if (f1.isDirectory()) {
                    n1 = "\t" + f1.getName().toLowerCase();
                } else {
                    n1 = f1.getName().toLowerCase();
                }

                if (f2.isDirectory()) {
                    n2 = "\t" + f2.getName().toLowerCase();
                } else {
                    n2 = f2.getName().toLowerCase();
                }

                return n1.compareTo(n2);
            }
        });
    }

    static void rename(@NonNull File absFromPath, @NonNull File absToPath) {
        File dirName = absToPath.getParentFile();
        if (dirName != null) {
            dirName.mkdirs();
        }
        if (! absFromPath.renameTo(absToPath)) {
            // hard to recover here, that would require to compute hash of overwritten file
            // additionally if code is executed here this might be caused by a bug elsewhere
            throw new RuntimeException("Cannot rename file " + absFromPath + " -> " + absToPath);
        }
    }

    static void createEmpty(@NonNull File absPath) {
        File dirName = absPath.getParentFile();
        if (dirName != null) {
            dirName.mkdirs();
        }
        try {
            if (absPath.exists() && absPath.length() == 0) {
                logger.warn("createEmpty file already exists");
            } else {
                if (! absPath.createNewFile()) {
                    throw new RuntimeException("createNewFile not true " + absPath);
                }
            }
        } catch (IOException ex) {
            throw new RuntimeException("Cannot create empty file " + absPath, ex);
        }
    }

    static void createAndCopy(@NonNull File absPath, @NonNull File srcContent) {
        try {
            File dirName = absPath.getParentFile();
            if (dirName != null) {
                dirName.mkdirs();
            }

            final InputStream in = new FileInputStream(srcContent);
            final OutputStream out = new FileOutputStream(absPath);

            byte[] buffer = new byte[4096];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            out.flush();
            out.close();

        } catch (IOException ex) {
            throw new RuntimeException("Cannot copy file " + srcContent + " to " + absPath);
        }
    }

    public static void deleteEmptyDirs(@NonNull File rootPath) {
        for (File child : rootPath.listFiles()) {
            if (child.isDirectory()) {
                deleteRecursiveEmptyDirs(child);
            }
        }
    }

    private static boolean deleteRecursiveEmptyDirs(@NonNull File dir) {
        if (dir.isDirectory()) {
            boolean canDeleteThis = true;
            for (File f : dir.listFiles()) {
                boolean canDeleteChild = deleteRecursiveEmptyDirs(f);
                if (! canDeleteChild) {
                    canDeleteThis = false;
                }
            }
            if (canDeleteThis) {
                logger.debug("Delete empty dir {}", dir);
                if (! dir.delete()) {
                    throw new RuntimeException("Cannot delete empty dir " + dir);
                }
            }
            return canDeleteThis;
        }
        return false;
    }

    public static void deleteRecursive(@NonNull File fileOrDirectory) {
        if (! fileOrDirectory.exists()) return;
        if (fileOrDirectory.isDirectory())
            for (File child : fileOrDirectory.listFiles())
                deleteRecursive(child);
        fileOrDirectory.delete();
    }

    public static long totalMem(Context context) {
        ActivityManager actManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        ActivityManager.MemoryInfo memInfo = new ActivityManager.MemoryInfo();
        actManager.getMemoryInfo(memInfo);
        return memInfo.totalMem;
    }

    public static StorageStats internalStorageStats(Context context) {
        return storageStats(context.getFilesDir().getPath());
    }

    public static StorageStats externalStorageStats(Context context) {
        return storageStats(Environment.getExternalStorageDirectory().getPath());
    }

    public static StorageStats storageStats(String path) {
        StorageStats result = new StorageStats();
        StatFs stat = new StatFs(path);
        long blockSize = stat.getBlockSize();
        result.totalBytes = stat.getBlockCount() * blockSize;
        result.availableBytes = stat.getAvailableBlocks() * blockSize;
        return result;
    }

    public static class StorageStats {
        public long availableBytes;
        public long totalBytes;
    }

    public static String byteToHex(final byte[] hash)
    {
        Formatter formatter = new Formatter();
        for (byte b : hash) {
            formatter.format("%02x", b);
        }
        String result = formatter.toString();
        formatter.close();
        return result;
    }

    public static String computeGitHash(@NonNull File file) {
        try {
            MessageDigest crypt = MessageDigest.getInstance("SHA-1");
            crypt.reset();

            String gitHeader = "blob " + file.length() + "\0";
            crypt.update(gitHeader.getBytes("UTF-8"));

            try {
                byte[] buffer = new byte[10 * 1024];
                InputStream stream = new BufferedInputStream(new FileInputStream(file));
                boolean done = false;
                while (! done) {
                    int i = stream.read(buffer);
                    if (i == -1) {
                        done = true;
                    } else {
                        crypt.update(buffer, 0, i);
                    }
                }
                stream.close();

            } catch (IOException ex) {
                throw new RuntimeException("Can't read file", ex);
            }
            return byteToHex(crypt.digest());

        } catch (NoSuchAlgorithmException |UnsupportedEncodingException ex) {
            throw new RuntimeException("Can't compute git hash", ex);
        }
    }

}
