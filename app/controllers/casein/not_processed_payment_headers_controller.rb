# coding: utf-8
#

module Casein
  class NotProcessedPaymentHeadersController < Casein::CaseinController
    before_action :get_payment_headers

    def index
    end

    def update_all
      payment_headers_params = params[:payment_headers]
      if payment_headers_params&.is_a?(Hash)
        PaymentHeader.transaction do
          payment_headers_params.values.each do |p|
            if p[:processed] != p[:current_processed]
              if payment_header = PaymentHeader.onlymine(current_user).find_by_id(p[:id])
                payment_header.processed = p[:processed]
                payment_header.process_user = current_user
                payment_header.process_date = Date.today
                payment_header.save!
              end
            end
          end
        end
      end
      flash[:notice] = '更新しました'
      redirect_to({action: :index}.merge(search_params))
    end

    private

    def get_payment_headers
      processed = params[:processed] == '1'
      query = PaymentHeader.onlymine(current_user).where(processed: processed)
      query = query.where(payable_on: Range.new(*parse_from_to)) if params[:from].present? || params[:to].present?
      query = query.search(params[:slip_no]) if params[:slip_no].present?
      @payment_headers = query.order(sort_order(:slip_no)).paginate(page: params[:page])
    end

    def parse_from_to
      from = (begin Date.parse(params[:from]) rescue Date.parse('1999/1/1') end)
      to = (begin Date.parse(params[:to]) rescue Date.parse('3000/1/1') end)
      [from, to]
    end

    def search_params
      {
        slip_no: params[:slip_no].presence,
        from: params[:from].presence,
        to: params[:to].presence
      }.compact
    end
  end
end
