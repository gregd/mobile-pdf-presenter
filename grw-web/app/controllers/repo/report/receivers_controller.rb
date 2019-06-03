class Repo::Report::ReceiversController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    if @items.empty?
      @report = nil
      return
    end

    if params[:tracking_id]
      @item = TrackerFile.find(params[:tracking_id]).tracker_item
    elsif params[:tracker_item_id]
      @item = TrackerItem.find(params[:tracker_item_id])
    else
      @item = @items.first
    end

    @selected_ua = current_user_role.reporting_emp(params[:ua_id].to_i) if params[:ua_id].present?

    @date_range = DateRange.new
    @date_range.set_start_end(params[:start_on], params[:end_on])

    @report = RepoReport::Receivers.compute(@item, @date_range, @selected_ua)
  end

  private

  def load_dictionaries
    @team = RepoReport::Receivers.team_for(current_user_role)
    @items = TrackerItem.active.options("main").to_a
  end

end
