# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
require "faker"
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Member.destroy_all
# Order.destroy_all
# Creation.destroy_all


# 5000.times do
#   Member.create(
#     created_at: Faker::Time.between_dates(from: Date.today - 30, to: Date.today, period: :morning)
#   )
# end

# dev_array = ["mobile", "tablet", "desktop"]
# devices = dev_array.sample

5000.times do
  dev_array = ["mobile", "tablet", "desktop"]
  devices = dev_array.sample
  member = Member.all.sample
  
  Creation.create(created_at: Faker::Time.between_dates(from: member.created_at + 30, to: Date.today, period: :afternoon),
     member: member, 
     creation_device: devices, 
     studio_tech_id: Faker::Number.number(digits: 2)
)
end

# 10000.times do
#   member = Member.all.sample
#   creation = Creation.all.sample
#   Order.create(
#     created_at: Faker::Time.between_dates(from: creation.created_at + 30, to: Date.today, period: :evening), member: member, creation: creation
#   )
# end

# # end
