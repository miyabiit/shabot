class Api::ProjectsController < ApiController
  def index
    @projects = Project.not_deleted
    if params[:name].present?
      @projects = @projects.where(name: params[:name])
    end
    if params[:category].present?
      @projects = @projects.where(category: params[:category])
    end
  end

  def show
    if params[:id].blank?
      render status: :unprocessable_entity
      return
    end
    @project = Project.not_deleted.find(params[:id])
  end
end
