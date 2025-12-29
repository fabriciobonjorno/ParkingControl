# frozen_string_literal: true

FactoryBot.define do
  factory :parking do
    sequence(:plate) { |n| "ABC-#{n.to_s.rjust(4, '0')}" }
    started_at { Time.current }
    paid_at { nil }
    left_at { nil }

    trait :paid do
      paid_at { Time.current }
    end

    trait :left do
      paid_at { 1.hour.ago }
      left_at { Time.current }
    end

    trait :active do
      left_at { nil }
    end

    trait :completed do
      paid_at { 1.hour.ago }
      left_at { 30.minutes.ago }
    end
  end
end
