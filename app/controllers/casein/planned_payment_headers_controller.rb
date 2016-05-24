# coding: utf-8
#

module Casein
  class PlannedPaymentHeadersController < PaymentBaseController
    target_model :payment_header

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

      def set_title
        case params[:action].to_s
        when 'index'
          @casein_page_title = "支払予定一覧"
        when 'new'
          @casein_page_title = "新規支払予定"
        when 'show'
          @casein_page_title = "支払予定詳細"
        when 'update'
          @casein_page_title = "支払予定更新"
        end
      end
  end
end
