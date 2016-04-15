class AddMyAccountToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :my_account, index: true
  end
end
