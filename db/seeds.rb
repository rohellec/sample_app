User.create!(name: "Dima Rogov",
             email: "ds.rogv@gmail.com",
             password: "ak%rog91",
             password_confirmation: "ak%rog91",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)
99.times do |i|
  name = Faker::Name.name
  email = "example-#{i + 1}@railstutorial.org"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end
