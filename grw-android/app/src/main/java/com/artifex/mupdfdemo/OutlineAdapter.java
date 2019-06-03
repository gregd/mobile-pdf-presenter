package com.artifex.mupdfdemo;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.grw.mobi.R;

public class OutlineAdapter extends BaseAdapter {
	private final OutlineItem    mItems[];
	private final LayoutInflater mInflater;
	public OutlineAdapter(LayoutInflater inflater, OutlineItem items[]) {
		mInflater = inflater;
		mItems    = items;
	}

	public int getCount() {
		return mItems.length;
	}

	public Object getItem(int arg0) {
		return null;
	}

	public long getItemId(int arg0) {
		return 0;
	}

	public View getView(int position, View convertView, ViewGroup parent) {
		View v;
		if (convertView == null) {
			v = mInflater.inflate(R.layout.mupdf_outline_entry, null);
		} else {
			v = convertView;
		}
		int level = mItems[position].level;
		if (level > 8) level = 8;
		String space = "";
		for (int i=0; i<level;i++)
			space += "   ";

		TextView titleView = (TextView)v.findViewById(R.id.title);
		TextView pageView = (TextView)v.findViewById(R.id.page);

		titleView.setText(space + mItems[position].title);
		pageView.setText(String.valueOf(mItems[position].page+1));

		if (mItems[position].read) {
			int c = 0xFF009900;
			titleView.setTextColor(c);
			pageView.setTextColor(c);
		} else {
			int c = Color.DKGRAY;
			titleView.setTextColor(c);
			pageView.setTextColor(c);
		}
		return v;
	}

}
