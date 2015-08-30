FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "youser#{n}" }
    password 'helloworld'
  end
end
