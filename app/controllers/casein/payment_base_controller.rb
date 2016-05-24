module Casein
  class PaymentBaseController < Casein::CaseinController
    include TargetModelFetching

    def index
      if params[:search]
        @payment_headers = payment_header_search.search(params[:search]).order(sort_order(:user_id)).paginate :page => params[:page]
      elsif params[:account_name]
        @payment_headers = payment_header_search.search_account(params[:account_name]).order(sort_order(:user_id)).paginate :page => params[:page]
      else
        @payment_headers = payment_header_search.order(sort_order(:user_id)).paginate :page => params[:page]
      end
      render action: :index
    end
  
    def show
      @payment_header = payment_header_find params[:id]
      render action: :show
    end

    def new_by_last
      @casein_page_title = 'New payment header'
      last_payment_header = payment_header_find params[:id]
      @payment_header = last_payment_header.dup
      @payment_header.slip_no = SlipNo.get_num
      @payment_header.user_id = current_user.id
      if @payment_header.save
        last_payment_header.payment_parts.each do |part|
          new_part = part.dup
          @payment_header.payment_parts << new_part
        end
      end
      render action: :show
    end


    def add_part
      @payment_header = payment_header_find(params[:id]) 
      @payment_header.payment_parts << PaymentPart.new
      render action: :show
    end
  
    def new
      @account = Account.find(params[:account_id]);
      @payment_header = build_payment_header(
        :user_id => current_user.id,
        :account_id => @account.id,
        :slip_no => SlipNo.get_num
        )
      render action: :new
    end

    def create
      @payment_header = build_payment_header(payment_header_params)
      @payment_header.payment_parts.push PaymentPart.new
    
      if @payment_header.save
        flash[:notice] = 'Payment header created'
        redirect_to_payment_show(@payment_header)
      else
        flash.now[:warning] = 'There were problems when trying to create a new payment header'
        render action: :new
      end
    end
  
    def update
      @payment_header = payment_header_find params[:id]
    
      if @payment_header.update_attributes payment_header_params
        flash[:notice] = 'Payment header has been updated'
        render action: :show
      else
        flash.now[:warning] = 'There were problems when trying to update this payment header'
        render action: :show
      end
    end
 
    def destroy
      @payment_header = payment_header_find params[:id]

      @payment_header.destroy
      flash[:notice] = 'Payment header has been deleted'
      redirect_to_payment_index
    end
  
    private
      
      def payment_header_params
        params.require(:payment_header).permit(:user_id, :account_id, :payable_on, :project_id, :org_name, :slip_no, :comment, :budget_code, :fee_who_paid, :my_account_id, :planned)
      end

      def payment_header_find(param_id)
        PaymentHeader.onlymine(@session_user).find(param_id)
      end

      def payment_header_search
        PaymentHeader.onlymine(@session_user)
      end

      def build_payment_header(attrs = {})
        PaymentHeader.new(attrs)
      end

      def redirect_to_payment_index
        redirect_to casein_payment_headers_path
      end

      def redirect_to_payment_show(payment_header)
        if payment_header.planned?
          redirect_to casein_planned_payment_header_path(payment_header)
        else
          redirect_to casein_payment_header_path(payment_header)
        end
      end
  end
end
