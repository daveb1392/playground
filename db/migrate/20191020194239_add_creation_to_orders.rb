class AddCreationToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :creation, foreign_key: true
  end
end
