# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
cookies = [
  { name: "Peanut Butter", slug: "peanut_butter", price: 160, status: :in_stock },
  { name: "Biscoff Lotus", slug: "biscoff", price: 180, status: :in_stock },
  { name: "Chocolate Chips", slug: "chocolate_chips", price: 100, status: :out_of_stock },
  { name: "Double Chocolate", slug: "double_chocolate", price: 120, status: :in_stock }
]

cookies.each do |cookie_attrs|
  product = Product.find_or_initialize_by(slug: cookie_attrs[:slug])
  product.assign_attributes(cookie_attrs)
  product.save!
end

puts "Seeded #{Product.count} Cozy Cookies products!"