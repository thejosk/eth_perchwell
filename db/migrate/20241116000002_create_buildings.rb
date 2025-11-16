class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.references :client, null: false, foreign_key: true
      t.string :street, null: false
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      t.timestamps
    end

    add_index :buildings, :street
  end
end
