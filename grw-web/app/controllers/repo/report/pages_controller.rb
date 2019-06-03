class Repo::Report::PagesController < ClientController
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
    @selected_ua = current_user_role.emp_position unless @selected_ua

    @date_range = DateRange.new(Date.today - 7.days, Date.today)
    @date_range.set_start_end(params[:start_on], params[:end_on])

    @selected_indicator = indicator_param
    @selected_indicator_name = RepoReport::Pages::INDICATOR_MAP[@selected_indicator]

    @as_chart = params[:as_chart] == "1" ? true : false

    @report = RepoReport::Pages.compute(@item, @date_range, @selected_ua)
  end

  private

  def load_dictionaries
    @indicators = RepoReport::Pages::INDICATOR_OPTIONS
    @team = RepoReport::Pages.team_for(current_user_role)
    @items = TrackerItem.active.content_pdf.options("main").to_a
  end

  def indicator_param
    allowed = RepoReport::Pages::INDICATOR_VALUES
    if allowed.include?(params[:indicator])
      params[:indicator]
    else
      allowed.first
    end
  end

end
