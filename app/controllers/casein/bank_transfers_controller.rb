# coding: utf-8

module Casein
  class BankTransfersController < Casein::CaseinController
    include TargetModelFetching
    target_model :bank_transfer

    def index
      params[:d] ||= 'down'
      @bank_transfers = BankTransfer.order(sort_order(:id)).paginate :page => params[:page]
    end

    def show
      @bank_transfer = BankTransfer.find params[:id]

      respond_to do |format|
        format.pdf do
          pdf = BankTransferPDF.new(@bank_transfer)
          pdf_filename = "bank-transfer-#{@bank_transfer.id}.pdf"
          send_data pdf.render,
            filename:  pdf_filename,
            type:      "application/pdf",
            disposition:  "attachment"
        end
        format.html
      end
    end

    def new
      @bank_transfer = BankTransfer.new
      @bank_transfer.set_default_values
    end
    
    def create
      @bank_transfer = BankTransfer.new(bank_transfer_params)
      @bank_transfer.user_id = current_user.id
      if @bank_transfer.valid?
        @bank_transfer.transfer!
      else
        render action: :new
      end
    end

    def destroy
      @bank_transfer = BankTransfer.find params[:id]
      @bank_transfer.destroy
      flash[:notice] = I18n.t('messages.destroy_model', model_name: model.model_name.human)
      redirect_to casein_bank_transfers_path
    end

    private
      
      def bank_transfer_params
        params.require(:bank_transfer).permit(:target_date, :amount, :src_my_account_id, :dst_my_account_id, :src_item_id, :dst_item_id, :project_id, :comment)
      end
  end
end
