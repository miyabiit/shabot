# coding: utf-8

module Casein
  class BankTransfersController < Casein::CaseinController
    include TargetModelFetching
    target_model :bank_transfer

    def index
      @bank_transfers = BankTransfer.order(sort_order(:id)).paginate :page => params[:page]
    end

    def show
      @bank_transfer = BankTransfer.find params[:id]

      respond_to do |format|
        format.pdf do

        end
      end
    end

    def new
      @bank_transfer = BankTransfer.new
      @bank_transfer.set_default_values
    end
    
    def create
      @bank_transfer = BankTransfer.new(params[:bank_transfer])
      @bank_transfer.user_id = current_user.id
      if @bank_transfer.valid?
        @bank_transfer.transfer!
      else
        render action: :new
      end
    end
  end
end
