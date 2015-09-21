User.create!(name: "Example user",
             email: "example@railstutorial.org",
             password: "foobar",
             password_confirmation: "foobar")
99.times do |i|
  name = Faker::Name.name
  email = "example-#{i + 1}@railstutorial.org"
  password = "password"
  User.create!(name: name, email: email,
               password: password, password_confirmation: password)
end
