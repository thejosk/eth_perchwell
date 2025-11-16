class CreateCustomFields < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_fields do |t|
      t.references :client, null: false, foreign_key: true
      t.string :name, null: false
      t.string :field_type, null: false
      t.text :enum_options

      t.timestamps
    end

    add_index :custom_fields, [:client_id, :name], unique: true
  end
end
