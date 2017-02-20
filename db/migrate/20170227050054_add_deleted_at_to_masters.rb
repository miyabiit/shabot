class AddDeletedAtToMasters < ActiveRecord::Migration
  def change
    %i(accounts casein_admin_users items my_accounts my_corporations projects).each do |table_name|
      add_column table_name, :deleted_at, :datetime
    end
  end
end
