# Scaffolding generated by Casein v5.1.1.5

module Casein
  class AccountsController < Casein::CaseinController
  
    ## optional filters for defining usage according to Casein::AdminUser access_levels
    # before_filter :needs_admin, :except => [:action1, :action2]
    # before_filter :needs_admin_or_current_user, :only => [:action1, :action2]
  
    def index
      @casein_page_title = 'お取引先'
  		@accounts =  Account.search(params[:search]).order(sort_order(:name)).paginate :page => params[:page]
    end
  
    def show
      @casein_page_title = 'View account'
      @account = Account.find params[:id]
    end
  
    def new
      @casein_page_title = 'Add a new account'
    	@account = Account.new
    end

    def create
      @account = Account.new account_params
    
      if @account.save
        flash[:notice] = 'Account created'
        redirect_to casein_accounts_path
      else
        flash.now[:warning] = 'There were problems when trying to create a new account'
        render :action => :new
      end
    end
  
    def update
      @casein_page_title = 'Update account'
      
      @account = Account.find params[:id]
    
      if @account.update_attributes account_params
        flash[:notice] = 'Account has been updated'
        redirect_to casein_accounts_path
      else
        flash.now[:warning] = 'There were problems when trying to update this account'
        render :action => :show
      end
    end
 
    def destroy
      @account = Account.find params[:id]

      @account.destroy
      flash[:notice] = 'Account has been deleted'
      redirect_to casein_accounts_path
    end
  
    private
      
      def account_params
        params.require(:account).permit(:name, :bank, :bank_branch, :category, :ac_no)
      end

  end
end
