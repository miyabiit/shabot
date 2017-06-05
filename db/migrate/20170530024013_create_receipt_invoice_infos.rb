class CreateReceiptInvoiceInfos < ActiveRecord::Migration
  def change
    create_table :receipt_invoice_infos do |t|
      t.references :receipt_header, null: false, index: true, foreign_key: true
      t.string :dst_post_num
      t.string :dst_address1
      t.string :dst_address2
      t.string :dst_person_name
      t.string :src_post_num
      t.string :src_address1
      t.string :src_address2
      t.string :src_tel
      t.string :src_fax
      t.string :trans_dst_bank_info
      t.string :trans_dst_bank_account_name

      t.timestamps null: false
    end
  end
end
