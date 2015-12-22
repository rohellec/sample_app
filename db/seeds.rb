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

users = User.order(:created_at).first(7)
users.each do |user|
  50.times { user.microposts.create!(content: Faker::Lorem.sentence(5)) }
end

users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |follower| follower.follow(user) }
followers.each { |followed| user.follow(followed) }
