# Scaffolding generated by Casein v5.1.1.5

module Casein
  class MyAccountsController < Casein::CaseinController
    include TargetModelFetching
    target_model :my_account
  
    ## optional filters for defining usage according to Casein::AdminUser access_levels
    # before_filter :needs_admin, :except => [:action1, :action2]
    # before_filter :needs_admin_or_current_user, :only => [:action1, :action2]
  
    def index
      @my_accounts = MyAccount.order(sort_order(:bank)).paginate :page => params[:page]
    end
  
    def show
      @my_account = MyAccount.find params[:id]
    end
  
    def new
      @my_account = MyAccount.new
    end

    def create
      @my_account = MyAccount.new my_account_params
    
      if @my_account.save
        flash[:notice] = I18n.t('messages.create_model', model_name: model.model_name.human)
        redirect_to casein_my_accounts_path
      else
        flash.now[:warning] = I18n.t('messages.failed_to_create', model_name: model.model_name.human)
        render :action => :new
      end
    end
  
    def update
      
      @my_account = MyAccount.find params[:id]
    
      if @my_account.update_attributes my_account_params
        flash[:notice] = I18n.t('messages.update_model', model_name: model.model_name.human)
        redirect_to casein_my_accounts_path
      else
        flash.now[:warning] = I18n.t('messages.failed_to_update', model_name: model.model_name.human)
        render :action => :show
      end
    end
 
    def destroy
      @my_account = MyAccount.find params[:id]

      @my_account.destroy
      flash[:notice] = I18n.t('messages.destroy_model', model_name: model.model_name.human)
      redirect_to casein_my_accounts_path
    end
  
    private
      
      def my_account_params
        params.require(:my_account).permit(:org_name, :bank, :bank_branch, :category, :ac_no, :account_id)
      end

  end
end
