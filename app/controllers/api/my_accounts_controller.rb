class Api::MyAccountsController < ApiController
  def index
    @my_accounts = MyAccount.not_deleted
    if params[:corporation_code].present?
      @my_accounts = @my_accounts.where(corporation_code: params[:corporation_code])
    end
  end

  def show
    if params[:id].blank?
      head :unprocessable_entity
      return
    end
    @my_account = MyAccount.not_deleted.find(params[:id])
  end
end
