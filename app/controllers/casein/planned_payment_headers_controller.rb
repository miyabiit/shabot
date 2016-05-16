# coding: utf-8
#

module Casein
  class PlannedPaymentHeadersController < PaymentBaseController
    before_action :set_planned

    private
      def payment_header_search
        super.planned_only
      end

      def build_payment_header(attrs = {})
        PaymentHeader.new({planned: true}.merge(attrs))
      end

      def set_planned
        @planned = true
      end

      def redirect_to_payment_index
        redirect_to casein_planned_payment_headers_path
      end
  end
end
