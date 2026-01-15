# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User.destroy_all
# User.create(email: 'murtaza@gmail.com', password: 'password', admin: true, first_name: 'Murtaza', last_name: 'Khan')

1.times do |index|
  u = User.new(
    #first_name: Faker::Name.first_name,
    first_name: "John",
    #last_name: Faker::Name.last_name,
    last_name: "Smith",
    #email: Faker::Internet.unique.email,
    email: "johnsmith@example.com",
    password: 'Password123#',
    confirmation_sent_at: "2023-03-31 04:22:33.308354",
    confirmed_at: "2023-03-31 04:22:33.308354",
    #image_file_name: rand(1..16)
  )
  u.save!
end
Rake::Task['populate_feeback_data:process'].invoke
