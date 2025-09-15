require 'rails_helper'

RSpec.describe 'Webhooks API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  it 'accepts inbound SMS' do
    payload = {
      from: '+18045551234',
      to: '+12016661234',
      type: 'sms',
      messaging_provider_id: 'message-1',
      body: 'Incoming SMS',
      attachments: nil,
      timestamp: '2024-11-01T14:00:00Z'
    }
    post '/api/v1/webhooks/sms', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:ok)
    expect(json['received']).to eq(true)
    expect(json['message']).to include('direction' => 'inbound')
  end

  it 'is idempotent for duplicate inbound IDs' do
    payload = {
      from: '+18045551234',
      to: '+12016661234',
      type: 'sms',
      messaging_provider_id: 'dup-1',
      body: 'Incoming SMS',
      attachments: nil,
      timestamp: '2024-11-01T14:00:00Z'
    }
    post '/api/v1/webhooks/sms', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:ok)
    post '/api/v1/webhooks/sms', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:ok)
    expect(Message.where(provider_message_id: 'dup-1', direction: 'inbound').count).to eq(1)
  end

  it 'accepts inbound Email' do
    payload = {
      from: 'contact@gmail.com',
      to: 'user@usehatchapp.com',
      xillio_id: 'message-3',
      body: '<html>Incoming</html>',
      attachments: [],
      timestamp: '2024-11-01T14:00:00Z'
    }
    post '/api/v1/webhooks/email', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:ok)
    expect(json['received']).to eq(true)
    expect(json['message']).to include('kind' => 'email')
  end
end
