namespace :hotfix do
  desc "update past payments (less than 2016/9) to processed"
  task update_past_payments_to_processed: :environment do
    PaymentHeader.where(processed: false, payable_on: (Date.new(2000, 1, 1) .. Date.new(2016, 8, 31))).update_all(processed: true, process_date: Date.today)
  end
end
