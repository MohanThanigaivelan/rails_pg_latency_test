FactoryBot.define do
  factory :user do
    email {  Faker::PhoneNumber.cell_phone }
    phone {  Faker::Internet.email  }
  end
end
