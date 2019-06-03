package com.grw.mobi.util;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.Checkable;
import android.widget.FrameLayout;
import android.widget.ImageView;
import com.grw.mobi.R;

public class CheckableFrameLayout extends FrameLayout implements Checkable {

    private boolean isChecked = false;
    private ImageView indicator;

    public CheckableFrameLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        indicator = (ImageView) findViewById(R.id.checkable_view);
    }

    public boolean isChecked() {
        return isChecked;
    }

    public void setChecked(boolean isChecked) {
        this.isChecked = isChecked;
        changeState(isChecked);
    }

    public void toggle() {
        this.isChecked = !this.isChecked;
        changeState(this.isChecked);
    }

    private void changeState(boolean show) {
        if (indicator == null) return;
        if (show) {
            indicator.setVisibility(VISIBLE);
        } else {
            indicator.setVisibility(GONE);
        }
    }
}
