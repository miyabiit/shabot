module PaymentHelper

  def payment_path(payment_header)
    casein_payment_header_path(payment_header)
  end

  def new_payment_path(payment_header)
    new_casein_payment_header_path(account_id: payment_header.account_id, planned: (1 if payment_header.planned?))
  end

  def new_by_last_payment_path(payment_header)
    new_by_last_casein_payment_header_path(payment_header)
  end
end
