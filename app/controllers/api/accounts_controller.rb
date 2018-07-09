class Api::AccountsController < ApiController
  def index
    @accounts = Account.not_deleted
  end

  def show
    if params[:id].blank?
      head :unprocessable_entity
      return
    end
    @account = Account.not_deleted.find(params[:id])
  end
end
