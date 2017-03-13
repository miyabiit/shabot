class AddDefaltValueToLinkedServices < ActiveRecord::Migration
  def change
    change_column_default :linked_services, :sync, false
  end
end
