# Scaffolding generated by Casein v5.1.1.5

module Casein
  class ReceiptHeadersController < Casein::CaseinController
    include TargetModelFetching
    target_model :receipt_header

    before_action :setup_search_form, only: [:index, :duplicate_monthly_data]
  
    ## optional filters for defining usage according to Casein::AdminUser access_levels
    # before_filter :needs_admin, :except => [:action1, :action2]
    # before_filter :needs_admin_or_current_user, :only => [:action1, :action2]
  
    def index
      @query = @form.create_query
      if params[:q]
        # 初期表示時以外
        @sum_amount = @query.sum_amount
      end
      @receipt_headers = @query.order(sort_order(:user_id)).paginate :page => params[:page]
    end
  
    def show
      @receipt_header = receipt_header_search.find params[:id]
    end
  
    def new
      @receipt_header = ReceiptHeader.new
    end

    def copy

      src_receipt_header = receipt_header_search.find(params[:id])
      @receipt_header = src_receipt_header.dup

      render :new
    end

    def create
      @receipt_header = ReceiptHeader.new receipt_header_params
      @receipt_header.user = @session_user
    
      if @receipt_header.save
        flash[:notice] = I18n.t('messages.create_model', model_name: model.model_name.human)
        redirect_to casein_receipt_header_path(@receipt_header, query_params)
      else
        flash.now[:warning] = I18n.t('messages.failed_to_create', model_name: model.model_name.human)
        render :action => :new
      end
    end
  
    def update
      @casein_page_title = I18n.t('views.receipt_header.update.title')
      
      @receipt_header = receipt_header_search.find params[:id]
      @receipt_header.user = @session_user
    
      if @receipt_header.update_attributes receipt_header_params
        flash[:notice] = I18n.t('messages.update_model', model_name: model.model_name.human)
        if params[:add_and_return_index]
          redirect_to casein_receipt_headers_path(query_params.merge({anchor: @receipt_header.id, anchor_id: @receipt_header.id}))
        else
          redirect_to casein_receipt_header_path(@receipt_header, query_params)
        end
      else
        flash.now[:warning] = I18n.t('messages.failed_to_update', model_name: model.model_name.human)
        render :action => :show
      end
    end
 
    def destroy
      @receipt_header = receipt_header_search.find params[:id]

      @receipt_header.destroy
      flash[:notice] = I18n.t('messages.destroy_model', model_name: model.model_name.human)
      redirect_to casein_receipt_headers_path(query_params)
    end

    def pdf
      receipt_header = receipt_header_search.find params[:id]
      pdf = ReceiptReportPDF.new(receipt_header)
      send_data pdf.render,
        filename:  "receipt.pdf",
        type:      "application/pdf",
        disposition:  "inline"
    end

    def duplicate_monthly_data
      if @form.duplicate_monthly_data
        flash[:notice] = "定例データを一括作成しました"
        redirect_to casein_receipt_headers_path(query_params)
      else
        @query = @form.create_query
        @receipt_headers = @query.order(sort_order(:user_id)).paginate :page => params[:page]
        render action: :index
      end
    end
  
    private
      def setup_search_form
        @form = ReceiptSearchForm.new(@session_user, params[:q])
      end
      
      def receipt_header_params
        params.require(:receipt_header).permit(:account_id, :receipt_on, :project_id, :comment, :item_id, :amount, :my_account_id, :no_monthly_report, :monthly_data)
      end

      def receipt_header_search
        ReceiptHeader.onlymine(@session_user)
      end
  end
end
