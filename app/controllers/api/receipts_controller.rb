class Api::ReceiptsController < ApiController
  def index
    if params[:fromym].blank? || params[:toym].blank?
      head :unprocessable_entity
      return
    end
    @receipts = ReceiptHeader.receipt_on_from_to(Date.strptime(params[:fromym], '%Y%m'), Date.strptime(params[:toym], '%Y%m').end_of_month)
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
      @receipts = @receipts.where(planned: planned)
    end
    if params[:project_name].present?
      @receipts = @receipts.joins(:project).where(projects: {name: params[:project_name]})
    end
    if params[:project_category].present?
      @receipts = @receipts.joins(:project).where(projects: {category: params[:project_category]})
    end
  end

  def show
    if params[:slipno].blank? && params[:id].blank?
      head :unprocessable_entity
      return
    end
    id = params[:slipno].presence || params[:id]
    @receipt = ReceiptHeader.find(id)
  end
end
