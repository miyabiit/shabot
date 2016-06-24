class AddColumnToAdminUser < ActiveRecord::Migration
  def change
    add_column :casein_admin_users, :member_code, :string
    add_column :casein_admin_users, :section, :string
  end
end
