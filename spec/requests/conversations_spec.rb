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
    expect(json).to be_an(Array)
    expect(json.first).to include('participants')
  end

  it 'lists messages for a conversation' do
    get '/api/v1/conversations'
    conversation_id = json.first['id']
    get "/api/v1/conversations/#{conversation_id}/messages"
    expect(response).to have_http_status(:ok)
    expect(json).to be_an(Array)
    expect(json.first).to include('from', 'to', 'kind', 'direction')
  end
end
