FactoryGirl.define do
  factory :user do
    name     "Dima Rogov"
    email    "drogov@foobar.net"
    password "foobar"
    password_confirmation "foobar"
  end
end
