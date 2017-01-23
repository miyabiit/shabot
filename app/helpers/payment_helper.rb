module PaymentHelper

  def payments_path
    casein_payment_headers_path(q: params[:q], c: params[:c], d: params[:d], page: params[:page])
  end

  def payment_path(payment_header)
    casein_payment_header_path(payment_header, q: params[:q], c: params[:c], d: params[:d], page: params[:page])
  end

  def new_payment_path(payment_header)
    new_casein_payment_header_path(account_id: payment_header.account_id, planned: (1 if payment_header.planned?), q: params[:q], c: params[:c], d: params[:d], page: params[:page])
  end

  def new_by_last_payment_path(payment_header)
    new_by_last_casein_payment_header_path(payment_header, q: params[:q], c: params[:c], d: params[:d], page: params[:page])
  end
end
