# require 'ffaker'

FactoryGirl.define do
  factory :user do
    email     Faker::Internet.email
    password 'test12345'
  end
end
