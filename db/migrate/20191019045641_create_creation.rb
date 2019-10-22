class CreateCreation < ActiveRecord::Migration[5.2]
  def change
    create_table :creations do |t|
      t.references :member, foreign_key: true
      t.integer :studio_tech_id
      t.string :creation_device
      t.timestamps
    end
  end
end
