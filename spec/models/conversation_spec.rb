require 'rails_helper'

RSpec.describe Conversation, type: :model do
  it 'normalizes and sorts participant pair' do
    c1 = Conversation.find_or_create_by_participants('B@Example.com', 'a@example.com')
    c2 = Conversation.find_or_create_by_participants('a@example.com', 'b@example.com')
    expect(c1.id).to eq(c2.id)
    expect(c1.participant_a).to eq('a@example.com')
    expect(c1.participant_b).to eq('b@example.com')
  end
end

