FactoryBot.define do
  factory :message do
    association :conversation
    kind { 'sms' }
    direction { 'outbound' }
    status { 'queued' }
    from_address { '+1' }
    to_address { '+2' }
    body { 'hello' }
    attachments { [] }
  end
end

