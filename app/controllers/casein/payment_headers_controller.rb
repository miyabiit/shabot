# coding: utf-8

module Casein
  class PaymentHeadersController < PaymentBaseController
    target_model :payment_header

    def pdf
      payment_header = payment_header_search.find params[:id]
      pdf = PaymentReport.new(payment_header)
      send_data pdf.render,
        filename:  "payment.pdf",
        type:      "application/pdf",
        disposition:  "inline"
    end

    private
    def payment_header_search
      super.result_only
    end

    def build_payment_header(attrs = {})
      PaymentHeader.new({planned: false}.merge(attrs))
    end
  end
end
