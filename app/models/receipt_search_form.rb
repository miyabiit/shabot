class ReceiptSearchForm
  include ActiveAttr::Model

  attribute :id               , type: String
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
    query = ReceiptHeader.onlymine(@current_user)
    query = query.where(id: self.id) if self.id.present?
    query = query.joins(:account).like_search('accounts.name', self.account_name) if self.account_name.present?
    query = query.where(receipt_on: ((self.from || Date.new(1999, 1, 1)) .. (self.to || Date.new(3000, 1, 1)))) if self.from || self.to
    if self.planned_true.present? ^ self.planned_false.present?
      query = query.where(planned: true)  if self.planned_true.present?
      query = query.where(planned: false) if self.planned_false.present?
    end
    query = query.where(monthly_data: true)  if self.monthly_data_true.present?
    query
  end

end
