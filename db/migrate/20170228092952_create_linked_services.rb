class CreateLinkedServices < ActiveRecord::Migration
  def change
    create_table :linked_services do |t|
      t.string :type
      t.integer :corporation_code, null: false
      t.boolean :sync
      t.datetime :synced_at

      t.timestamps null: false
    end

    add_index :linked_services, :corporation_code
  end
end
