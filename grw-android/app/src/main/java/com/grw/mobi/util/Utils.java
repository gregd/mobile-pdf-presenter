package com.grw.mobi.util;

import android.content.Context;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class Utils {

    public static boolean isBlank(CharSequence cs) {
        int strLen;
        if (cs == null || (strLen = cs.length()) == 0) {
            return true;
        }
        for (int i = 0; i < strLen; i++) {
            if ((Character.isWhitespace(cs.charAt(i)) == false)) {
                return false;
            }
        }
        return true;
 	}

    public static String capitalizeFirstLetter(String s) {
        if (s.length() == 0) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }

    public static boolean isZipcode(String s) {
        return s != null && s.matches("\\d{2}-\\d{3}");
    }

    public static String normalize(String s) {
        if (s == null) return null;
        s = s.trim();
        // clean horizontal whitespace characters, do not remove new line characters
        s = s.replaceAll("[ \\t\\u00A0]+", " ");
        // handle case of only new line chars string
        s = s.replaceAll("^\\n+$", "");
        return (s.length() == 0) ? null : s;
    }

    public static String readAsset(Context context, String filename) {
        StringBuilder sb = new StringBuilder();
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(context.getAssets().open(filename), "UTF-8"));
            String mLine = reader.readLine();
            while (mLine != null) {
                sb.append(mLine);
                mLine = reader.readLine();
            }
        } catch (IOException e) {
            throw new RuntimeException("Cannot read asset file " + filename, e);
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    throw new RuntimeException("Cannot close asset file " + filename, e);
                }
            }
        }
        return sb.toString();
    }

    public static String getFileName(String path) {
        int i = path.lastIndexOf("/");
        if (i == -1) {
            return path;
        } else {
            return path.substring(i + 1);
        }
    }

}
