require 'rails_helper'

RSpec.describe 'Conversations API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  before do
    # Create some data through the API to ensure routes work end-to-end
    post '/api/v1/messages/sms', params: {
      from: '+12016661234', to: '+18045551234', type: 'sms', body: 'hello'
    }.to_json, headers: headers
    post '/api/v1/webhooks/sms', params: {
      from: '+18045551234', to: '+12016661234', type: 'sms', messaging_provider_id: 'x', body: 'hi'
    }.to_json, headers: headers
  end

  it 'lists conversations' do
    get '/api/v1/conversations'
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('application/json')
    expect(json).to be_an(Array)
    expect_conversation_json(json.first)
  end

  it 'lists messages for a conversation' do
    get '/api/v1/conversations'
    conversation_id = json.first['id']
    get "/api/v1/conversations/#{conversation_id}/messages"
    expect(response).to have_http_status(:ok)
    expect(json).to be_an(Array)
    # First message was outbound 'hello', then inbound 'hi'
    expect_message_json(json.first, kind: 'sms', direction: 'outbound', from: '+12016661234', to: '+18045551234', status: 'queued', body: 'hello', attachments: [])
    expect_message_json(json.second, kind: 'sms', direction: 'inbound', from: '+18045551234', to: '+12016661234', status: 'queued', body: 'hi', attachments: [])
  end

  it 'normalizes participants and sorts conversations by last_message_at desc' do
    # isolate from before block data
    Message.delete_all
    Conversation.delete_all

    # Create two conversations with mixed casing and reversed order
    post '/api/v1/messages/sms', params: { from: 'A@EXAMPLE.com', to: 'B@Example.COM', type: 'sms', body: '1' }.to_json, headers: headers
    conv1_participants = ['a@example.com', 'b@example.com']
    post '/api/v1/messages/sms', params: { from: 'c@example.com', to: 'd@example.com', type: 'sms', body: '2' }.to_json, headers: headers

    # After initial creation, two conversations exist
    get '/api/v1/conversations'
    expect(json.length).to eq(2)
    # participants are normalized and sorted
    expect(json.map { |c| c['participants'] }).to include(conv1_participants, ['c@example.com','d@example.com'])

    # Bump second conversation to be most recent
    post '/api/v1/webhooks/sms', params: { from: 'd@example.com', to: 'c@example.com', type: 'sms', messaging_provider_id: 'z', body: '3' }.to_json, headers: headers
    get '/api/v1/conversations'
    expect(json.first['participants']).to eq(['c@example.com','d@example.com'])
  end
end
