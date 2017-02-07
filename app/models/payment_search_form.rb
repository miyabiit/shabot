class PaymentSearchForm
  include ActiveAttr::Model

  attribute :slip_no          , type: String
  attribute :account_name     , type: String
  attribute :from             , type: Date
  attribute :to               , type: Date
  attribute :planned_true     , type: Boolean
  attribute :planned_false    , type: Boolean
  attribute :monthly_data_true, type: Boolean

  def initialize(current_user, attrs={}, &block)
    super(attrs, &block)
    @current_user = current_user
  end

  def create_query
    query = PaymentHeader.onlymine(@current_user)
    query = query.search(self.slip_no) if self.slip_no.present?
    query = query.search_account(self.account_name) if self.account_name.present?
    query = query.where(payable_on: ((from || Date.new(1999, 1, 1)) .. (to || Date.new(3000, 1, 1)))) if self.from || self.to
    if self.planned_true.present? ^ self.planned_false.present?
      query = query.where(planned: true)  if self.planned_true.present?
      query = query.where(planned: false) if self.planned_false.present?
    end
    query = query.where(monthly_data: true)  if self.monthly_data_true.present?
    query
  end

end
