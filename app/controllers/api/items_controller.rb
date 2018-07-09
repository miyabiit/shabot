class Api::ItemsController < ApiController
  def index
    @items = Item.all
  end

  def show
    if params[:id].blank?
      render status: :unprocessable_entity
      return
    end
    @item = Item.find(params[:id])
  end
end
