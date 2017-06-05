class ReceiptInvoiceInfo < ActiveRecord::Base
  belongs_to :receipt_header

  validates :dst_post_num, :src_post_num, allow_blank: true, length: { maximum: 8}
  validates :dst_address1, :dst_address2, :src_address1, :src_address2, :trans_dst_bank_info,:dst_person_name, :trans_dst_bank_account_name, allow_blank: true, length: { maximum: 40 }
end
