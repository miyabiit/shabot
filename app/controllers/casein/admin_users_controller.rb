require 'securerandom'

module Casein
  class AdminUsersController < Casein::CaseinController
    include TargetModelFetching
    target_model 'casein/admin_user'

    before_filter :needs_admin, :except => [:show, :destroy, :update, :update_password]
    before_filter :needs_admin_or_current_user, :only => [:show, :destroy, :update, :update_password]
 
    def index
      @users = Casein::AdminUser.order(sort_order(:login)).paginate :page => params[:page]
    end
 
    def new
      @casein_admin_user = Casein::AdminUser.new
      @casein_admin_user.time_zone = Rails.configuration.time_zone
    end
  
    def create

      generate_random_password if params[:generate_random_password]

      @casein_admin_user = Casein::AdminUser.new casein_admin_user_params
    
      if @casein_admin_user.save
        flash[:notice] = "An email has been sent to " + @casein_admin_user.name + " with the new account details"
        redirect_to casein_admin_users_path
      else
        flash.now[:warning] = "There were problems when trying to create a new user"
        render :action => :new
      end
    end
  
    def show
      @casein_admin_user = Casein::AdminUser.find params[:id]
      @casein_page_title = @casein_admin_user.name + " > 詳細"
    end
 
    def update
      @casein_admin_user = Casein::AdminUser.find params[:id]
      @casein_page_title = @casein_admin_user.name + " > 更新"

      if @casein_admin_user.update_attributes casein_admin_user_params
        flash[:notice] = @casein_admin_user.name + " has been updated"
      else
        flash.now[:warning] = "There were problems when trying to update this user"
        render :action => :show
        return
      end
      
      if @session_user.is_admin?
        redirect_to casein_admin_users_path
      else
        redirect_to :controller => :casein, :action => :index
      end
    end
 
    def update_password
      @casein_admin_user = Casein::AdminUser.find params[:id]
      @casein_page_title = @casein_admin_user.name + " > パスワード更新"
       
      if @casein_admin_user.valid_password? params[:form_current_password]
        if params[:casein_admin_user][:password].blank? && params[:casein_admin_user][:password_confirmation].blank?
          flash[:warning] = "New password cannot be blank"
        elsif @casein_admin_user.update_attributes casein_admin_user_params
          flash[:notice] = "Your password has been changed"
        else
          flash[:warning] = "There were problems when trying to change your password"
        end
      else
        flash[:warning] = "The current password is incorrect"
      end
      
      redirect_to :action => :show
    end
 
    def reset_password
      @casein_admin_user = Casein::AdminUser.find params[:id]
      @casein_page_title = @casein_admin_user.name + " > パスワード初期化"
       
      if params[:generate_random_password].blank? && params[:casein_admin_user][:password].blank? && params[:casein_admin_user][:password_confirmation].blank?
        flash[:warning] = "New password cannot be blank"
      else
        generate_random_password if params[:generate_random_password]
        @casein_admin_user.notify_of_new_password = true unless (@casein_admin_user.id == @session_user.id && params[:generate_random_password].blank?)

        if @casein_admin_user.update_attributes casein_admin_user_params
          unless @casein_admin_user.notify_of_new_password
            flash[:notice] = "Your password has been reset"
          else    
            flash[:notice] = "Password has been reset and " + @casein_admin_user.name + " has been notified by email"
          end
        else
          flash[:warning] = "There were problems when trying to reset this user's password"
        end
      end

      redirect_to :action => :show
    end
 
    def destroy
      user = Casein::AdminUser.find params[:id]
      if user.is_admin? == false || Casein::AdminUser.has_more_than_one_admin
        user.logical_delete
        flash[:notice] = user.name + " has been deleted"
      end
      redirect_to casein_admin_users_path
    end

    private

      def generate_random_password
        random_password = random_string = SecureRandom.hex
        params[:casein_admin_user] = Hash.new if params[:casein_admin_user].blank?
        params[:casein_admin_user].merge! ({:password => random_password, :password_confirmation => random_password})
      end

      def casein_admin_user_params
        params.require(:casein_admin_user).permit(:login, :name, :email, :time_zone, :access_level, :password, :password_confirmation, :member_code, :section)
      end
  end
end
