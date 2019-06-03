package com.grw.mobi.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.os.Environment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class ImgUtils {
    private static final Logger logger = LoggerFactory.getLogger(ImgUtils.class);

    // bigger pictures make application crash because of memory problems
    public static final int sMaxWidthOrHeight = 1000;

    public static void initDirectory(Context context) throws IOException {
        File dir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        File nomedia = new File(dir, ".nomedia");
        if (nomedia.createNewFile()) {
            logger.debug("nomedia file created");
        }
    }

    public static File getTmpImageFile(Context context) {
        File dir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        return new File(dir, "attachment.jpeg");
    }

    public static String getDestImageFile(Context context, String uuid) {
        File dir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        return new File(dir, uuid + ".jpeg").getPath();
    }

    // http://stackoverflow.com/a/4250279/3315
    public static void resize(String pInputFile, String pOutputFile, int pDesiredSize) throws Exception {
        System.gc();

        // Get the source image's dimensions
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(pInputFile, options);

        int srcWidth = options.outWidth;
        int srcHeight = options.outHeight;
        int srcMaxWH = srcHeight > srcWidth ? srcHeight : srcWidth;

        // Only scale if the source is big enough. This code is just trying to fit a image into a certain width.
        if(pDesiredSize > srcMaxWH)
            pDesiredSize = srcMaxWH;

        // Calculate the correct inSampleSize/scale value. This helps reduce memory use. It should be a power of 2
        // from: http://stackoverflow.com/questions/477572/android-strange-out-of-memory-issue/823966#823966
        int inSampleSize = 1;
        while(srcMaxWH / 2 > pDesiredSize){
            srcMaxWH /= 2;
            inSampleSize *= 2;
        }

        float desiredScale = (float) pDesiredSize / srcMaxWH;

        // Decode with inSampleSize
        options.inJustDecodeBounds = false;
        options.inDither = false;
        options.inSampleSize = inSampleSize;
        options.inScaled = false;
        options.inPreferredConfig = Bitmap.Config.ARGB_8888;
        Bitmap sampledSrcBitmap = BitmapFactory.decodeFile(pInputFile, options);

        // Resize
        ConvertParams c = getConvertParams(getOrientation(pInputFile));
        Matrix matrix = new Matrix();
        if (c.shouldRotate()) {
            matrix.setRotate(c.rotate);
        }
        if (c.shouldSetScale()) {
            matrix.setScale(c.scale1, c.scale2);
        }
        if (c.shouldPostScale()) {
            matrix.postScale(c.post1 * desiredScale, c.post2 * desiredScale);
        } else {
            matrix.postScale(desiredScale, desiredScale);
        }
        Bitmap scaledBitmap = Bitmap.createBitmap(sampledSrcBitmap, 0, 0, sampledSrcBitmap.getWidth(), sampledSrcBitmap.getHeight(), matrix, true);
        sampledSrcBitmap = null;

        // Save
        FileOutputStream out = new FileOutputStream(pOutputFile);
        scaledBitmap.compress(Bitmap.CompressFormat.JPEG, 85, out);
        scaledBitmap = null;
        System.gc();

        copyExif(pInputFile, pOutputFile, ExifInterface.ORIENTATION_NORMAL);
    }

    public static class ConvertParams {
        public int scale1 = 1;
        public int scale2 = 1;
        public int post1 = 1;
        public int post2 = 1;
        public int rotate = 0;
        public ConvertParams() {}
        public void setScale(int s1, int s2) {
            scale1 = s1;
            scale2 = s2;
        }
        public boolean shouldSetScale() {
            return scale1 != 1 || scale2 != 1;
        }
        public void postScale(int p1, int p2) {
            post1 = p1;
            post2 = p2;
        }
        public boolean shouldPostScale() {
            return post1 != 1 || post2 != 1;
        }
        public void setRotate(int r) {
            rotate = r;
        }
        public boolean shouldRotate() {
            return rotate != 0;
        }
    }

    // http://stackoverflow.com/a/20480741/3315
    public static ConvertParams getConvertParams(int orientation) throws IOException {
        ConvertParams r = new ConvertParams();
        switch (orientation) {
            case ExifInterface.ORIENTATION_NORMAL:
                break;
            case ExifInterface.ORIENTATION_FLIP_HORIZONTAL:
                r.setScale(-1, 1);
                break;
            case ExifInterface.ORIENTATION_ROTATE_180:
                r.setRotate(180);
                break;
            case ExifInterface.ORIENTATION_FLIP_VERTICAL:
                r.setRotate(180);
                r.postScale(-1, 1);
                break;
            case ExifInterface.ORIENTATION_TRANSPOSE:
                r.setRotate(90);
                r.postScale(-1, 1);
                break;
            case ExifInterface.ORIENTATION_ROTATE_90:
                r.setRotate(90);
                break;
            case ExifInterface.ORIENTATION_TRANSVERSE:
                r.setRotate(-90);
                r.postScale(-1, 1);
                break;
            case ExifInterface.ORIENTATION_ROTATE_270:
                r.setRotate(-90);
                break;
            default:
                break;
        }
        return r;
    }

    // http://stackoverflow.com/a/33553329/3315
    public static void copyExif(String oldPath, String newPath, Integer overwriteOrientation) throws IOException {
        String[] attributes = new String[] {
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.TAG_DATETIME,
                ExifInterface.TAG_MAKE,
                ExifInterface.TAG_MODEL,
                ExifInterface.TAG_FLASH,
                //ExifInterface.TAG_IMAGE_WIDTH,          // is this really needed?
                //ExifInterface.TAG_IMAGE_LENGTH,         // after scale and rotation we should set new values
                ExifInterface.TAG_GPS_LATITUDE,
                ExifInterface.TAG_GPS_LONGITUDE,
                ExifInterface.TAG_GPS_LATITUDE_REF,
                ExifInterface.TAG_GPS_LONGITUDE_REF,
                ExifInterface.TAG_EXPOSURE_TIME,
                ExifInterface.TAG_APERTURE,
                ExifInterface.TAG_ISO,
                //ExifInterface.TAG_DATETIME_DIGITIZED,     // API 23
                //ExifInterface.TAG_SUBSEC_TIME,
                //ExifInterface.TAG_SUBSEC_TIME_ORIG,
                //ExifInterface.TAG_SUBSEC_TIME_DIG,
                //ExifInterface.TAG_SUBSECTIME,
                ExifInterface.TAG_GPS_ALTITUDE,
                ExifInterface.TAG_GPS_ALTITUDE_REF,
                ExifInterface.TAG_GPS_TIMESTAMP,
                ExifInterface.TAG_GPS_DATESTAMP,
                ExifInterface.TAG_WHITE_BALANCE,
                ExifInterface.TAG_FOCAL_LENGTH,
                ExifInterface.TAG_GPS_PROCESSING_METHOD,
        };

        ExifInterface oldExif = new ExifInterface(oldPath);
        ExifInterface newExif = new ExifInterface(newPath);
        for (String attr : attributes) {
            String value = oldExif.getAttribute(attr);
            if (value != null) {
                newExif.setAttribute(attr, value);
            }
        }
        if (overwriteOrientation != null) {
            newExif.setAttribute(ExifInterface.TAG_ORIENTATION, String.valueOf(overwriteOrientation));
        }
        newExif.saveAttributes();
    }

    public static int getOrientation(String path) throws IOException {
        ExifInterface exif = new ExifInterface(path);
        return exif.getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_UNDEFINED);
    }

}
