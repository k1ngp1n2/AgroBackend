class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :messures
      t.integer :price
      t.references :category

      t.timestamps
    end
  end
end