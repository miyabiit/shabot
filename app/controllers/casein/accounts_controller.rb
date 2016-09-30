# Scaffolding generated by Casein v5.1.1.5

module Casein
  class AccountsController < Casein::CaseinController
    include TargetModelFetching
    target_model :account

    ## optional filters for defining usage according to Casein::AdminUser access_levels
    # before_filter :needs_admin, :except => [:action1, :action2]
    # before_filter :needs_admin_or_current_user, :only => [:action1, :action2]
  
    def index
      @accounts =  Account.search(params[:search]).order(sort_order(:name)).paginate :page => params[:page]
    end
  
    def show
      @account = Account.find params[:id]
    end
  
    def new
      @account = Account.new
    end

    def create
      @account = Account.new account_params
    
      if @account.save
        flash[:notice] = I18n.t('messages.create_model', model_name: model.model_name.human)
        redirect_to casein_accounts_path
      else
        flash.now[:warning] = I18n.t('messages.failed_to_create', model_name: model.model_name.human)
        render :action => :new
      end
    end
  
    def update
      @account = Account.find params[:id]
    
      if @account.update_attributes account_params
        flash[:notice] = I18n.t('messages.update_model', model_name: model.model_name.human)
        if params[:new_slip]
          redirect_to new_casein_payment_header_path(account_id: @account.id)
        else
          redirect_to casein_accounts_path
        end
      else
        flash.now[:warning] = I18n.t('messages.failed_to_update', model_name: model.model_name.human)
        render :action => :show
      end
    end
 
    def destroy
      @account = Account.find params[:id]

      @account.destroy
      flash[:notice] = I18n.t('messages.destroy_model', model_name: model.model_name.human)
      redirect_to casein_accounts_path
    end
  
    private
      
      def account_params
        params.require(:account).permit(:name, :bank, :bank_branch, :category, :ac_no, :my_group)
      end

  end
end
