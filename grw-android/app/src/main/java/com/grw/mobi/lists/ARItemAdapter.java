package com.grw.mobi.lists;

import android.content.Context;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;

import com.grw.mobi.R;
import com.grw.mobi.Session;
import com.grw.mobi.util.CheckableFrameLayout;

import org.solovyev.android.views.llm.DividerItemDecoration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class ARItemAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    public static final int LINEAR = 1;
    public static final int GRID = 2;

    Context context;
    Session session;

    List<ARItem> items;
    RecyclerView recycler;
    int layoutType;
    HashMap<Integer, ARItem> categoryMap = new HashMap<>();

    public ARItemAdapter(Context context, Session session, RecyclerView recycler, List<ARItem> items, int layoutType) {
        super();
        this.context = context;
        this.session = session;
        this.recycler = recycler;
        this.layoutType = layoutType;
        setModels(items);

        switch (layoutType) {
            case LINEAR:
                // Do not add decoration each time a new adapter is created. There is
                // no getItemDecoration so have use getLayoutManager as a workaround.
                if (recycler.getLayoutManager() == null) {
                    recycler.addItemDecoration(new DividerItemDecoration(context, null));
                }
                recycler.setLayoutManager(new LinearLayoutManager(context));
                break;

            case GRID:
                // Xml layout have to use AutofitRecyclerView. That class initializes the grid manager.
                // FIXME AutofitRecyclerView has some problem with below decoration, picture aspect ration might be wrong
                //recycler.addItemDecoration(new MarginDecoration(context, R.dimen.picture_grid_margin));
                break;

            default:
                throw new RuntimeException("layoutType not implemented " + layoutType);
        }
    }

    public void setModels(List<ARItem> items) {
        categoryMap.clear();
        this.items = items;
        for (ARItem item : items) {
            if (categoryMap.containsKey(item.getViewType())) continue;
            categoryMap.put(item.getViewType(), item);
        }
    }

    @Override
    public int getItemViewType(int position) {
        return items.get(position).getViewType();
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        ARItem item = categoryMap.get(viewType);
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        return item.createViewHolder(inflater, parent);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        items.get(position).bindView(holder);
        if (choiceMode != ChoiceMode.NONE) {
            displaySelection(holder, position);
        }
    }

    public int findFirstVisibleItemPosition() {
        switch (layoutType) {
            case LINEAR:
                LinearLayoutManager layoutManager = (LinearLayoutManager) recycler.getLayoutManager();
                return layoutManager.findFirstVisibleItemPosition();

            case GRID:
                GridLayoutManager gridLayoutManager = (GridLayoutManager) recycler.getLayoutManager();
                return gridLayoutManager.findFirstVisibleItemPosition();

            default:
                throw new RuntimeException("Unknown layoutType " + layoutType);
        }
    }

    public void setFirstVisibleItem(int position) {
        switch (layoutType) {
            case LINEAR:
                LinearLayoutManager layoutManager = (LinearLayoutManager) recycler.getLayoutManager();
                layoutManager.scrollToPosition(position);
                return;

            case GRID:
                GridLayoutManager gridLayoutManager = (GridLayoutManager) recycler.getLayoutManager();
                gridLayoutManager.scrollToPosition(position);
                return;

            default:
                throw new RuntimeException("Unknown layoutType " + layoutType);
        }
    }

    // Very simple emulation of ListView.CHOICE_MODE_SINGLE functionality. Activity has
    // to save state of currently selected items to the bundle. onClickHandler should
    // also call setSelected().
    // Test multi-choice mode when needed

    public enum ChoiceMode { NONE, SINGLE, MULTI }
    private ChoiceMode choiceMode = ChoiceMode.NONE;
    private SparseBooleanArray selectedItems = new SparseBooleanArray();

    public void setChoiceMode(ChoiceMode mode) {
        this.choiceMode = mode;
    }

    private void displaySelection(RecyclerView.ViewHolder holder, int position) {
        View v;
        if (holder.itemView instanceof CheckableFrameLayout) {
            CheckableFrameLayout c = (CheckableFrameLayout) holder.itemView;
            c.setChecked(selectedItems.get(position, false));

        } else if ((v = holder.itemView.findViewById(R.id.item_radio_btn)) != null) {
            RadioButton r = (RadioButton) v;
            r.setChecked(selectedItems.get(position, false));

        } else {
            // use activated state and state drawables
            holder.itemView.setActivated(selectedItems.get(position, false));
        }
    }

    public void toggleSelection(int pos) {
        if (selectedItems.get(pos, false)) {
            selectedItems.delete(pos);
        } else {
            if (choiceMode == ChoiceMode.SINGLE) {
                clearSelections();
            }
            selectedItems.put(pos, true);
        }
        notifyItemChanged(pos);
    }

    public void setSelected(int pos) {
        if (isSelected(pos)) {
            return;
        }
        if (choiceMode == ChoiceMode.SINGLE) {
            clearSelections();
        }
        selectedItems.put(pos, true);
        notifyItemChanged(pos);
    }

    public void clearSelection(int pos) {
        if (! isSelected(pos)) {
            return;
        }
        if (selectedItems.get(pos, false)) {
            selectedItems.delete(pos);
        }
        notifyItemChanged(pos);
    }

    public void clearSelections() {
        for (int i : getSelectedItemsPositions()) {
            clearSelection(i);
        }
    }

    public boolean isSelected(int pos) {
        return selectedItems.get(pos, false);
    }

    public List<Integer> getSelectedItemsPositions() {
        List<Integer> items = new ArrayList<>(selectedItems.size());
        for (int i = 0; i < selectedItems.size(); i++) {
            items.add(selectedItems.keyAt(i));
        }
        return items;
    }

}
