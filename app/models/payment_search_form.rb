class PaymentSearchForm
  include ActiveAttr::Model

  attribute :slip_no          , type: String
  attribute :account_name     , type: String
  attribute :from             , type: Date
  attribute :to               , type: Date
  attribute :planned_true     , type: Boolean
  attribute :planned_false    , type: Boolean
  attribute :monthly_data_true, type: Boolean

  validates :from, presence: true, on: :duplicate_monthly_data
  validates :to, presence: true, on: :duplicate_monthly_data
  validates :monthly_data_true, presence: true, on: :duplicate_monthly_data
  validate  :validate_form_to_range, on: :duplicate_monthly_data

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

  def duplicate_monthly_data
    return false unless valid?(:duplicate_monthly_data)
    PaymentHeader.transaction do 
      query = create_query
      query.where(monthly_data: true).where.not(payable_on: nil).each do |payment|
        payment.duplicate({
          user_id: @current_user.id,
          planned: false,
          payable_on: payment.payable_on.next_month
        })
      end
    end
    true
  end

  def validate_form_to_range
    if from.present? && to.present?
      if to.prev_month.prev_month >= from
        errors.add :base, '開始日と終了日は2ヶ月未満の期間を指定してください'
      end
    end
  end

end
