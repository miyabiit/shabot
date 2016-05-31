class CreateNumberMasters < ActiveRecord::Migration
  def change
    create_table :number_masters do |t|
      t.string  :name
      t.integer :now_val
      t.integer :max_val
      t.integer :min_val
      t.string :prefix
      t.integer :steps , :notnull => true, :default => 1
      t.string :type
      t.timestamps null: false
    end
    add_index :number_masters, :type
  end
end
