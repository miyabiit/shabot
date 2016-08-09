namespace :hotfix do
  desc "fix invalid user"
  task fix_invalid_user: :environment do
    ActiveRecord::Base.transaction do
      dummy_user = Casein::AdminUser.create(login: 'deleted_user', name: '削除済みユーザー', email: 'deleted_user@example.com', password: 'p4fYM2pYUywy', password_confirmation: 'p4fYM2pYUywy')
      PaymentHeader.where("NOT EXISTS(SELECT casein_admin_users.id FROM casein_admin_users WHERE casein_admin_users.id = payment_headers.user_id)").find_each do |payment_header|
        payment_header.user_id = dummy_user.id
        payment_header.save
      end
    end
  end
end
