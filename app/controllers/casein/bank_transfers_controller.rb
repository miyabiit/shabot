# coding: utf-8

module Casein
  class BankTransfersController < Casein::CaseinController
    def new
      @form = BankTransferForm.new
      @form.set_default_values
    end
    
    def create
      @form = BankTransferForm.new(params[:bank_transfer_form])
      @form.user_id = current_user.id
      if @form.valid?
        @payment, @receipt = @form.create!
      else
        render action: :new
      end
    end
  end
end
