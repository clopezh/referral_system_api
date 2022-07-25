FactoryBot.define do
  factory :user do
    name { Faker::Name.name_with_middle }
    email { Faker::Internet.email }
    role_id { 1 }
    active { Faker::Boolean.boolean }
  end
end
