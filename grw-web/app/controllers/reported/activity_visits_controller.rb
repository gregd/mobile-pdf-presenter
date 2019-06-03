class Reported::ActivityVisitsController < ClientController
  include PermControl

  def new

  end

  def create

  end

  def edit
    @visit = ActivityVisit::AsEdit.find(params[:id])
  end

  def update

  end

  def destroy

  end

  private

end
