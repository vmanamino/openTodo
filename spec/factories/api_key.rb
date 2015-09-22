FactoryGirl.define do
  factory :api_key do
    expires_at 1.day.from_now
    user
  end
end
