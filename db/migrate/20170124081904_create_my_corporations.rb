class CreateMyCorporations < ActiveRecord::Migration
  def change
    create_table :my_corporations, id: false do |t|
      t.integer :code, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :my_corporations, :code, unique: true
  end
end
