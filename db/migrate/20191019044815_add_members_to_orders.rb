class AddMembersToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :member, foreign_key: true
  end
end
