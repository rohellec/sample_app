FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person_#{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"
    activated true
    activated_at Time.zone.now

    factory :admin do
      admin true
    end
  end

  factory :micropost do
    sequence(:content) { |n| "Lorem ipsum_#{n}" }
    user
  end
end
