class Api::PaymentsController < ApiController
  def index
    if params[:fromym].blank? || params[:toym].blank?
      head :unprocessable_entity
      return
    end
    @payments = PaymentHeader.payable_on_from_to(Date.strptime(params[:fromym], '%Y%m'), Date.strptime(params[:toym], '%Y%m').end_of_month)
    if params[:planned].present? || params[:planned] == false
      planned = params[:planned]
      if planned.is_a? String
        planned = case planned
                  when 'T', 't', 'True', 'TRUE', 'true', '1'
                    true
                  else
                    false
                  end
      end
      @payments = @payments.where(planned: planned)
    end
    if params[:project_name].present?
      @payments = @payments.joins(:project).where(projects: {name: params[:project_name]})
    end
    if params[:project_category].present?
      @payments = @payments.joins(:project).where(projects: {category: params[:project_category]})
    end
  end

  def show
    if params[:slip_no].blank? && params[:id].blank?
      head :unprocessable_entity
      return
    end
    if params[:slip_no].present?
      @payment = PaymentHeader.find_by!(slip_no: params[:slip_no])
    else
      @payment = PaymentHeader.find(params[:id])
    end
  end
end
