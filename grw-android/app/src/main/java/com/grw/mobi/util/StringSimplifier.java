package com.grw.mobi.util;

import java.text.Normalizer;
import java.util.HashMap;
import java.util.regex.Pattern;

// http://stackoverflow.com/a/1453284/3315
public class StringSimplifier {

    public static String simplify(String str) {
        if (str == null) {
            return null;
        }
        str = stripDiacritics(str);
        str = stripNonDiacritics(str);
        return str.toLowerCase();
    }

    public static final String TEST_SIMPLIFIER = "7ę3ął";
    public static final char DEFAULT_REPLACE_CHAR = ' ';
    public static final String DEFAULT_REPLACE = String.valueOf(DEFAULT_REPLACE_CHAR);
    private static final HashMap<String, String> NONDIACRITICS;
    static {
        NONDIACRITICS = new HashMap<>();

        NONDIACRITICS.put(".", DEFAULT_REPLACE);
        NONDIACRITICS.put("\"", DEFAULT_REPLACE);
        NONDIACRITICS.put("'", DEFAULT_REPLACE);
        NONDIACRITICS.put(" ", DEFAULT_REPLACE);
        NONDIACRITICS.put("]", DEFAULT_REPLACE);
        NONDIACRITICS.put("[", DEFAULT_REPLACE);
        NONDIACRITICS.put(")", DEFAULT_REPLACE);
        NONDIACRITICS.put("(", DEFAULT_REPLACE);
        NONDIACRITICS.put("=", DEFAULT_REPLACE);
        NONDIACRITICS.put("!", DEFAULT_REPLACE);
        NONDIACRITICS.put("/", DEFAULT_REPLACE);
        NONDIACRITICS.put("\\", DEFAULT_REPLACE);
        NONDIACRITICS.put("&", DEFAULT_REPLACE);
        NONDIACRITICS.put(",", DEFAULT_REPLACE);
        NONDIACRITICS.put("?", DEFAULT_REPLACE);
        NONDIACRITICS.put("°", DEFAULT_REPLACE);
        NONDIACRITICS.put("|", DEFAULT_REPLACE);
        NONDIACRITICS.put("<", DEFAULT_REPLACE);
        NONDIACRITICS.put(">", DEFAULT_REPLACE);
        NONDIACRITICS.put(";", DEFAULT_REPLACE);
        NONDIACRITICS.put(":", DEFAULT_REPLACE);
        //NONDIACRITICS.put("_", DEFAULT_REPLACE); // do not remove '_' because of ims brick names
        NONDIACRITICS.put("#", DEFAULT_REPLACE);
        NONDIACRITICS.put("~", DEFAULT_REPLACE);
        NONDIACRITICS.put("+", DEFAULT_REPLACE);
        NONDIACRITICS.put("*", DEFAULT_REPLACE);

        //Replace non-diacritics as their equivalent characters
        NONDIACRITICS.put("Ł", "l");
        NONDIACRITICS.put("ł", "l");
        NONDIACRITICS.put("ß", "ss");
        NONDIACRITICS.put("æ", "ae");
        NONDIACRITICS.put("ø", "o");
        NONDIACRITICS.put("©", "c");
        NONDIACRITICS.put("\u00D0", "d"); // All Ð ð from http://de.wikipedia.org/wiki/%C3%90
        NONDIACRITICS.put("\u00F0", "d");
        NONDIACRITICS.put("\u0110", "d");
        NONDIACRITICS.put("\u0111", "d");
        NONDIACRITICS.put("\u0189", "d");
        NONDIACRITICS.put("\u0256", "d");
        NONDIACRITICS.put("\u00DE", "th"); // thorn Þ
        NONDIACRITICS.put("\u00FE", "th"); // thorn þ
    }

    private static String stripNonDiacritics(String orig) {
        StringBuffer ret = new StringBuffer();
        String lastchar = null;
        for (int i = 0; i < orig.length(); i++) {
            String source = orig.substring(i, i + 1);
            String replace = NONDIACRITICS.get(source);
            String toReplace = replace == null ? String.valueOf(source) : replace;
            if (DEFAULT_REPLACE.equals(lastchar) && DEFAULT_REPLACE.equals(toReplace)) {
                toReplace = "";
            } else {
                lastchar = toReplace;
            }
            ret.append(toReplace);
        }
        if (ret.length() > 0 && DEFAULT_REPLACE_CHAR == ret.charAt(ret.length() - 1)) {
            ret.deleteCharAt(ret.length() - 1);
        }
        return ret.toString();
    }

    /*
    Special regular expression character ranges relevant for simplification -> see http://docstore.mik.ua/orelly/perl/prog3/ch05_04.htm
    InCombiningDiacriticalMarks: special marks that are part of "normal" ä, ö, î etc..
        IsSk: Symbol, Modifier see http://www.fileformat.info/info/unicode/category/Sk/list.htm
        IsLm: Letter, Modifier see http://www.fileformat.info/info/unicode/category/Lm/list.htm
     */
    private static final Pattern DIACRITICS_AND_FRIENDS
            = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");

    private static String stripDiacritics(String str) {
        str = Normalizer.normalize(str, Normalizer.Form.NFD);
        str = DIACRITICS_AND_FRIENDS.matcher(str).replaceAll("");
        return str;
    }
}
