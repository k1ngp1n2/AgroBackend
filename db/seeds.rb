# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all
Category.destroy_all
Product.destroy_all

def random_inn
  inn = ""
  9.times do
    inn += rand(0..9).to_s
  end
  inn
end

users = 5.times.map do
  {
    email: FFaker::Internet.safe_email,
    name: FFaker::NameRU.name,
    password: 'password',
    telephone: FFaker::PhoneNumber.short_phone_number,
    address: FFaker::AddressRU.city,
    description: FFaker::HipsterIpsum.paragraph
  }
end

User.create! users

farmers = User.last(2)

farmers.each do |s|
  s.add_role :farmer
  s.farmer = Farmer.create(inn: random_inn, description: FFaker::HipsterIpsum.paragraph, address: FFaker::AddressRU.city)
end

category_array = %w(мясо овощи фрукты специи ингредиенты)
category_hash = 5.times.map do |t|
  {
      name: category_array[t-1]
  }
end

Category.create! category_hash
category = Category.all

10.times do
  category.each do |c|
    case c.name
    when "мясо"
      Product.create(name: FFaker::Food.unique.meat, messures: "kg", category: c)
    when "овощи"
      Product.create(name: FFaker::Food.unique.vegetable, messures: "kg", category: c)
    when "фрукты"
      Product.create(name: FFaker::Food.unique.fruit, messures: "kg", category: c)
    when "специи"
      Product.create(name: FFaker::Food.unique.herb_or_spice, messures: "kg", category: c)
    when "ингредиенты"
      Product.create(name: FFaker::Food.unique.ingredient, messures: "kg", category: c)
    end
  end
end