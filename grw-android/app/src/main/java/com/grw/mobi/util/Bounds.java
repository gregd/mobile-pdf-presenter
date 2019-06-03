package com.grw.mobi.util;

public class Bounds {
    public LatLng sw;
    public LatLng ne;

    public Bounds(LatLng pSw, LatLng pNe) {
        sw = pSw;
        ne = pNe;
    }

    public boolean crossesMeridian() {
      return sw.lng > ne.lng;
    }

    public static Bounds fromPointAndRadius(LatLng point, double radiusKM) {
        LatLng p0 = LatLng.endPoint(point, 0, radiusKM);
        LatLng p90 = LatLng.endPoint(point, 90, radiusKM);
        LatLng p180 = LatLng.endPoint(point, 180, radiusKM);
        LatLng p270 = LatLng.endPoint(point, 270, radiusKM);
        LatLng sw = new LatLng(p180.lat, p270.lng);
        LatLng ne = new LatLng(p0.lat, p90.lng);
        return new Bounds(sw,ne);
    }
}
