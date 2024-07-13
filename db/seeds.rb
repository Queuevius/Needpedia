# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User.destroy_all
# User.create(email: 'murtaza@gmail.com', password: 'password', admin: true, first_name: 'Murtaza', last_name: 'Khan')

20.times do |index|
  u = User.new(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.unique.email,
      password: 'password',
      # image_file_name: rand(1..16)
  )
  u.save!
end
Rake::Task['populate_feeback_data:process'].invoke
