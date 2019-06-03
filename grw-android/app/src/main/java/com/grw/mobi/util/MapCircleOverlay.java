package com.grw.mobi.util;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Point;
import org.osmdroid.util.GeoPoint;
import org.osmdroid.util.TileSystem;
import org.osmdroid.views.MapView;
import org.osmdroid.views.overlay.Overlay;

public class MapCircleOverlay extends Overlay {
    private GeoPoint point;
    private Paint paint1;
    private float radius; //in meters

    public MapCircleOverlay(Context context, GeoPoint point, float radius) {
        super(context);

        this.point = point;
        this.radius = radius;

        paint1 = new Paint();
        paint1.setARGB(0, 255, 255, 255);
        paint1.setAntiAlias(true);
    }

    public void setARGB(int a, int r, int g, int b) {
        paint1.setARGB(a, r, g, b);
    }

    @Override
    public void draw(Canvas canvas, MapView mapView, boolean shadow) {
        if (shadow) return;

        Point pt = mapView.getProjection().toPixels(point, null);
        float projectedRadius = radiusInPixels(mapView);

        paint1.setAlpha(50);
        paint1.setStyle(Paint.Style.FILL);
        canvas.drawCircle(pt.x, pt.y, projectedRadius, paint1);

        paint1.setAlpha(150);
        paint1.setStyle(Paint.Style.STROKE);
        canvas.drawCircle(pt.x, pt.y, projectedRadius, paint1);
    }

    private float radiusInPixels(MapView mapView) {
        return radius / (float) TileSystem.GroundResolution(point.getLatitude(), mapView.getZoomLevel());
    }

}
