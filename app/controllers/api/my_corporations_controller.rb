class Api::MyCorporationsController < ApiController
  def index
    @my_corporations = MyCorporation.not_deleted
  end

  def show
    if params[:id].blank? && params[:code].blank?
      head :unprocessable_entity
      return
    end
    if params[:code].present?
      @my_corporation = MyCorporation.not_deleted.find_by!(code: params[:code])
    else
      @my_corporation = MyCorporation.not_deleted.find(params[:id])
    end
  end
end
