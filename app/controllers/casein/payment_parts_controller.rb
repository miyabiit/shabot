# Scaffolding generated by Casein v5.1.1.5

module Casein
  class PaymentPartsController < Casein::CaseinController
    include TargetModelFetching
    target_model :payment_part
  
    ## optional filters for defining usage according to Casein::AdminUser access_levels
    # before_filter :needs_admin, :except => [:action1, :action2]
    # before_filter :needs_admin_or_current_user, :only => [:action1, :action2]
  
    def index
      @casein_page_title = 'Payment parts'
  		@payment_parts = PaymentPart.order(sort_order(:payment_header_id)).paginate :page => params[:page]
    end
  
    def show
      @casein_page_title = 'View payment part'
      @payment_part = PaymentPart.find params[:id]
    end
  
    def new
      @casein_page_title = 'Add a new payment part'
    	@payment_part = PaymentPart.new
    end

    def create
      @payment_part = PaymentPart.new payment_part_params
    
      if @payment_part.save
        flash[:notice] = I18n.t('messages.create_model', model_name: model.model_name.human)
        redirect_to casein_payment_parts_path
      else
        flash.now[:warning] = I18n.t('messages.failed_to_create', model_name: model.model_name.human)
        render :action => :new
      end
    end
  
    def update
      @casein_page_title = 'Update payment part'
      
      @payment_part = PaymentPart.find params[:id]
    
      if @payment_part.update_attributes payment_part_params
        flash[:notice] = I18n.t('messages.update_model', model_name: model.model_name.human)
				@payment_header = PaymentHeader.find @payment_part.payment_header_id
        redirect_to_payment_header(@payment_header)
      else
        flash.now[:warning] = I18n.t('messages.failed_to_update', model_name: model.model_name.human)
				@payment_header = PaymentHeader.find @payment_part.payment_header_id
        redirect_to_payment_header(@payment_header)
      end
    end
 
    def destroy
      @payment_part = PaymentPart.find params[:id]
			@payment_header = PaymentHeader.find @payment_part.payment_header_id

      @payment_part.destroy
      flash[:notice] = I18n.t('messages.destroy_model', model_name: model.model_name.human)
      redirect_to_payment_header(@payment_header)
    end
  
    private
      
      def payment_part_params
        params.require(:payment_part).permit(:payment_header_id, :item_id, :amount)
      end

      def redirect_to_payment_header(payment_header)
        if payment_header.try(:planned)
          redirect_to casein_planned_payment_header_path(payment_header)
        else
          redirect_to casein_payment_header_path(payment_header)
        end
      end

  end
end
