module Casein
  class PaymentHeadersController < Casein::CaseinController
    include TargetModelFetching

    target_model :payment_header

    before_action :setup_search_form, only: [:index, :duplicate_monthly_data]

    def index
      @query = @form.create_query
      if params[:q]
        # 初期表示時以外
        @sum_amount = @query.sum_amount
      end

      @payment_headers = @query.order(sort_order(:user_id)).order(:id).paginate :page => params[:page]
      render action: :index
    end
  
    def show
      @payment_header = payment_header_find params[:id]
      render action: :show
    end

    def new_by_last
      @casein_page_title = 'New payment header'
      last_payment_header = payment_header_find params[:id]
      PaymentHeader.transaction do
        @payment_header = last_payment_header.duplicate(user_id: current_user.id)
      end
      render action: :show
    end

    def new
      @account = Account.find(params[:account_id]);
      @payment_header = build_payment_header(
        :user_id => current_user.id,
        :account_id => @account.id,
        :slip_no => SlipNo.get_num,
        :payment_type => :eb,
        :planned => params[:planned].present?
        )
      render action: :new
    end

    def create
      @payment_header = build_payment_header(payment_header_params)
      @payment_header.payment_parts.push PaymentPart.new
    
      if @payment_header.save
        flash[:notice] = I18n.t('messages.create_model', model_name: model_human_name)
        redirect_to_payment_show(@payment_header)
      else
        flash.discard(:notice)
        flash.now[:warning] = create_error_message(@payment_header)
        render action: :new
      end
    end
  
    def update
      @payment_header = payment_header_find params[:id]
    
      if @payment_header.update_attributes payment_header_params
        flash[:notice] = I18n.t('messages.update_model', model_name: model_human_name)
        if params[:add_and_return_index]
          redirect_to_payment_index(anchor: @payment_header.id, anchor_id: @payment_header.id)
        else
          render action: :show
        end
      else
        flash.discard(:notice)
        flash.now[:warning] = create_error_message(@payment_header)
        render action: :show
      end
    end
 
    def destroy
      @payment_header = payment_header_find params[:id]

      if @payment_header.processed?
        flash.discard(:notice)
        flash[:warning] = '処理済の支払い申請は削除できません'
      else
        @payment_header.destroy
        flash[:notice] = I18n.t('messages.destroy_model', model_name: model_human_name)
      end
      redirect_to_payment_index
    end

    def pdf
      payment_header = payment_header_find params[:id]
      pdf = PaymentReportPDF.new(payment_header)
      send_data pdf.render,
        filename:  "payment.pdf",
        type:      "application/pdf",
        disposition:  "inline"
    end
  
    def duplicate_monthly_data
      if @form.valid?(:duplicate_monthly_data) 
        PaymentHeader.duplicate_monthly_data(current_user, params[:ids])
        flash[:notice] = "定例データを一括作成しました"
        redirect_to_payment_index
      else
        @query = @form.create_query
        @payment_headers = @query.order(sort_order(:user_id)).order(:id).paginate :page => params[:page]
        render action: :index
      end
    end

    private

      def setup_search_form
        @form = PaymentSearchForm.new(@session_user, params[:q])
      end
      
      def payment_header_params
        params.require(:payment_header).permit(:user_id, :account_id, :payable_on, :project_id, :org_name, :slip_no, :comment, :budget_code, :fee_who_paid, :my_account_id, :planned, :no_monthly_report, :payment_type, :monthly_data, payment_parts_attributes: [:id, :item_id, :amount, :_destroy])
      end

      def payment_header_find(param_id)
        PaymentHeader.onlymine(@session_user).find(param_id)
      end

      def build_payment_header(attrs = {})
        PaymentHeader.new(attrs)
      end

      def redirect_to_payment_index(additional_params={})
        redirect_to casein_payment_headers_path(query_params.merge(additional_params))
      end

      def redirect_to_payment_show(payment_header)
        redirect_to casein_payment_header_path(payment_header, query_params)
      end

      def create_error_message(payment_header, action=nil)
        action ||= payment_header.new_record? ? 'create' : 'update'
        (I18n.t("messages.failed_to_#{action}", model_name: model_human_name) + ' <br> ' +
           payment_header.errors.full_messages.map{|msg| "・#{msg}"}.join('<br>')).html_safe
      end

      def model_human_name
        '支払申請書'
      end
  end
end
