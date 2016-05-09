module PaymentHelper

  def payment_path(payment_header)
    if payment_header.try(:planned)
      casein_planned_payment_header_path(payment_header)
    else
      casein_payment_header_path(payment_header)
    end
  end

  def new_payment_path(payment_header)
    if payment_header.try(:planned)
      new_casein_planned_payment_header_path(account_id: payment_header.account_id)
    else
      new_casein_payment_header_path(account_id: payment_header.account_id)
    end
  end

  def new_by_last_payment_path(payment_header)
    if payment_header.try(:planned)
      new_by_last_casein_planned_payment_header_path(payment_header)
    else
      new_by_last_casein_payment_header_path(payment_header)
    end
  end
end
