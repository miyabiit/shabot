class AddApiTokenToCaseinAdminUsers < ActiveRecord::Migration
  def change
    add_column :casein_admin_users, :api_token, :string
  end
end
