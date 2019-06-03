class Repo::Report::TotalController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    if @items.empty?
      @report = nil
      return
    end

    @selected_ua = current_user_role.reporting_emp(params[:ua_id].to_i) if params[:ua_id].present?
    @selected_ua = current_user_role.emp_position unless @selected_ua

    @date_range = DateRange.new(Date.today - 7.days, Date.today)
    @date_range.set_start_end(params[:start_on], params[:end_on])

    @selected_indicator = indicator_param

    @as_chart = params[:as_chart] == "1" ? true : false

    @report = RepoReport::Total.compute(@items, @date_range, @selected_ua)
  end

  private

  def load_dictionaries
    @indicators = RepoReport::Items::INDICATOR_OPTIONS
    @team = current_user_role.reporting_emps
    @items = TrackerItem.active.options("main").to_a
  end

  def indicator_param
    allowed = RepoReport::Items::INDICATOR_VALUES
    if allowed.include?(params[:indicator])
      params[:indicator]
    else
      allowed.first
    end
  end

end
