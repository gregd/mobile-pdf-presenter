class Admin::EmpPositionsController < AdminController
  before_action :require_selected_account, :load_dictionaries

  def index
    @emps = EmpPosition::AsEdit.order("path")
  end

  def new
    @emp_position = EmpPosition::AsEdit.new

    if params[:parent_id].present?
      @emp_position.parent_id = params[:parent_id]
    end
  end

  def create
    @emp_position = EmpPosition::AsEdit.new(emp_position_params)
    if @emp_position.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @emp_position = EmpPosition::AsEdit.find(params[:id])
    render :new
  end

  def update
    @emp_position = EmpPosition::AsEdit.find(params[:id])
    if @emp_position.update_attributes(emp_position_params)
      rw_redirect_back
    else
      render :new
    end
  end

  def destroy
    emp_position = EmpPosition.find(params[:id])
    emp_position.destroy!
    flash[:success] = "Emp Position #{emp_position.name} usunięte."
    rw_redirect_back
  end

  private

  def emp_position_params
    params.require(:emp_position).permit!
  end

  def load_dictionaries
    @parents = EmpPosition::AsDict.for_users
  end

end
