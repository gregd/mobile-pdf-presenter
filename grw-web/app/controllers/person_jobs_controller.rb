class PersonJobsController < ClientController
  include PermControl
  before_action :load_dictionaries

  def edit
    @person_job = PersonJob.find(params[:id])
  end

  def update
    @person_job = PersonJob.find(params[:id])
    if @person_job.update_attributes(person_job_params)
      flash[:success] = "Zmiany zapisane."
      rw_redirect_back
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def load_dictionaries
    @job_titles = JobTitle::AsDict.list
  end

  def person_job_params
    params.require(:person_job).permit(
      :job_title_id)
  end

end
