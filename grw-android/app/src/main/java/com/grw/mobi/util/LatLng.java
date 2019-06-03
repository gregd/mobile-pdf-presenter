package com.grw.mobi.util;

import android.location.Location;

public class LatLng {
    public static final double EARTH_RADIUS_IN_KMS = 6371.01;

    public static double deg2rad(double degrees) {
        return degrees / 180.0 * Math.PI;
    }

    public static double rad2deg(double rad) {
        return rad * 180.0 / Math.PI;
    }

    public double lat;
    public double lng;

    public LatLng(double pLat, double pLng) {
        lat = pLat;
        lng = pLng;
    }

    public LatLng(Location loc) {
        lat = loc.getLatitude();
        lng = loc.getLongitude();
    }

    @Override public boolean equals(Object aThat) {
        if (this == aThat) return true;
        if (!(aThat instanceof LatLng)) return false;
        LatLng that = (LatLng)aThat;
        return new Double(lat).equals(that.lat) && new Double(lng).equals(lng);
    }

    // Returns distance in meters
    public int mDistanceTo(LatLng pSecond) {
        if (this.equals(pSecond)) {
            return 0;
        }
        return (int) Math.round(kmDistanceTo(pSecond) * 1000);
    }

    // Returns distance in KM
    public double kmDistanceTo(LatLng pSecond) {
        if (this.equals(pSecond)) {
            return 0.0;
        }
        return EARTH_RADIUS_IN_KMS * Math.acos( Math.sin(deg2rad(lat)) * Math.sin(deg2rad(pSecond.lat)) +
                Math.cos(deg2rad(lat)) * Math.cos(deg2rad(pSecond.lat)) *
                        Math.cos(deg2rad(pSecond.lng) - deg2rad(lng)));
    }

    public static LatLng endPoint(LatLng start, double heading, double distance) {
        double radius = EARTH_RADIUS_IN_KMS;
        double lat = deg2rad(start.lat);
        double lng = deg2rad(start.lng);
        heading = deg2rad(heading);
        double end_lat = Math.asin(Math.sin(lat) * Math.cos(distance/radius) +
                Math.cos(lat) * Math.sin(distance/radius) * Math.cos(heading));
        double end_lng = lng + Math.atan2(Math.sin(heading) * Math.sin(distance/radius) * Math.cos(lat),
                Math.cos(distance/radius) - Math.sin(lat) * Math.sin(end_lat));

        return new LatLng(rad2deg(end_lat), rad2deg(end_lng));
    }

    public static String queryCond(LatLng ll, int radiusM) {
        Bounds bounds = Bounds.fromPointAndRadius(ll, (double)radiusM / 1000.0);
        LatLng sw = bounds.sw;
        LatLng ne = bounds.ne;
        String lngSql = bounds.crossesMeridian() ?
                "(lng < " + ne.lng + " OR lng > " + sw.lng + ")" :
                "lng > " + sw.lng + " AND lng < " + ne.lng;
        return "lat > " + sw.lat + " AND lat < " + ne.lat + " AND " + lngSql;
    }

}
