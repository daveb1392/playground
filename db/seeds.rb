# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
require "faker"
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User.destroy_all
# Order.destroy_all


1000.times do
  User.create(
    created_at: Faker::Time.between_dates(from: Date.today - 30, to: Date.today, period: :morning),
  )
end



1000.times do
  user = User.all.sample
  Order.create(
    created_at: Faker::Time.between_dates(from: user.created_at + 30, to: Date.today, period: :evening), user: user,
  )
end

# end
