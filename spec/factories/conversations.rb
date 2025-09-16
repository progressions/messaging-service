FactoryBot.define do
  factory :conversation do
    participant_a { 'a@example.com' }
    participant_b { 'b@example.com' }
  end
end

