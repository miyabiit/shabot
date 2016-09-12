# Scaffolding generated by Casein v5.1.1.5

module Casein
  class ReportsController < Casein::CaseinController
  
    def index
      @casein_page_title = 'Reports'
    end
  
    def pdf_each_project
      from, to = parse_from_to
      payment_headers = PaymentHeader.where(payable_on: from..to)
      pdf = EachProjectPaymentList.new(payment_headers)
      pdf_filename = "payment-project-" + from.strftime("%y%m%d") + "-" + to.strftime("%y%m%d") + '.pdf'
      send_data pdf.render,
        filename:  pdf_filename,
        type:      "application/pdf",
        # disposition:  "inline"
        disposition:  "attachment"
    end

    def pdf_each_day
      from, to = parse_from_to
      payment_headers = PaymentHeader.where(payable_on: from..to)
      pdf = EachDayPaymentList.new(payment_headers)
      pdf_filename = "payment-eachday-" + from.strftime("%y%m%d") + "-" + to.strftime("%y%m%d") + '.pdf'
      send_data pdf.render,
        filename:  pdf_filename,
        type:      "application/pdf",
        # disposition:  "inline"
        disposition:  "attachment"
    end

    def pdf_payment_receipt
      from, to = parse_from_to
      pdf = PaymentReceipt.new(from, to)
      send_data pdf.render,
        filename:  "payment-receipt-#{from.strftime("%y%m%d")}-#{to.strftime("%y%m%d")}.pdf",
        type:      "application/pdf",
        disposition:  "attachment"
    end

    def csv_receipt
      from, to = parse_from_to
      csv = ReceiptCSV.new(from, to)
      send_data csv.generate,
        filename:  "receipt-#{from.strftime("%y%m%d")}-#{to.strftime("%y%m%d")}.csv",
        type:      "text/csv; charset=shift_jis",
        disposition:  "attachment"
    end

    def csv_payment
      from, to = parse_from_to
      csv = PaymentCSV.new(from, to)
      send_data csv.generate,
        filename:  "payment-#{from.strftime("%y%m%d")}-#{to.strftime("%y%m%d")}.csv",
        type:      "text/csv; charset=shift_jis",
        disposition:  "attachment"
    end

    def pdf_not_processed_payment
      from, to = parse_from_to
      payment_headers = PaymentHeader.where(processed: false, payable_on: from...to)
      pdf = ProcessPaymentList.new(payment_headers, '未払申請一覧', params[:from], params[:to])
      pdf_filename = "not-processed-payment-" + from.strftime("%y%m%d") + "-" + to.strftime("%y%m%d") + '.pdf'
      send_data pdf.render,
        filename:  pdf_filename,
        type:      "application/pdf",
        disposition:  "attachment"
    end

    def pdf_processed_payment
      from, to = parse_from_to
      payment_headers = PaymentHeader.where(processed: true, payable_on: from...to)
      pdf = ProcessPaymentList.new(payment_headers, '支払処理済申請一覧', params[:from], params[:to])
      pdf_filename = "processed-payment-" + from.strftime("%y%m%d") + "-" + to.strftime("%y%m%d") + '.pdf'
      send_data pdf.render,
        filename:  pdf_filename,
        type:      "application/pdf",
        disposition:  "attachment"
    end

    private

      def parse_from_to
        from = (begin Date.parse(params[:from]) rescue Date.parse('1999/1/1') end)
        to = (begin Date.parse(params[:to]) rescue Date.parse('3000/1/1') end)
        [from, to]
      end

  end
end
