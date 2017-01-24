class ReceiptSearchForm
  include ActiveAttr::Model

  attribute :id               , type: String
  attribute :account_name     , type: String
  attribute :from             , type: Date
  attribute :to               , type: Date
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
    query = ReceiptHeader.onlymine(@current_user)
    query = query.where(id: self.id) if self.id.present?
    query = query.joins(:account).like_search('accounts.name', self.account_name) if self.account_name.present?
    query = query.where(receipt_on: ((self.from || Date.new(1999, 1, 1)) .. (self.to || Date.new(3000, 1, 1)))) if self.from || self.to
    query = query.where(monthly_data: true)  if self.monthly_data_true.present?
    query
  end

  def duplicate_monthly_data
    return false unless valid?(:duplicate_monthly_data)
    ReceiptHeader.transaction do 
      query = create_query
      query.where(monthly_data: true).where.not(receipt_on: nil).each do |receipt|
        receipt.duplicate({
          user_id: @current_user.id,
          receipt_on: receipt.receipt_on.next_month
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
