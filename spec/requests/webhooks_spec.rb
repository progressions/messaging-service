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
    expect(response.media_type).to eq('application/json')
    expect(json['received']).to be(true)
    expect_message_json(json['message'], kind: 'sms', direction: 'inbound', from: payload[:from], to: payload[:to], status: 'queued', body: payload[:body], attachments: [])
    # provider_message_id mapping
    created = Message.find(json['message']['id'])
    expect(created.provider_message_id).to eq('message-1')
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
    id1 = json.dig('message', 'id')
    expect(response).to have_http_status(:ok)
    post '/api/v1/webhooks/sms', params: payload.to_json, headers: headers
    id2 = json.dig('message', 'id')
    expect(response).to have_http_status(:ok)
    expect(id2).to eq(id1)
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
    expect(json['received']).to be(true)
    expect_message_json(json['message'], kind: 'email', direction: 'inbound', from: payload[:from], to: payload[:to], status: 'queued', body: payload[:body], attachments: payload[:attachments])
    created = Message.find(json['message']['id'])
    expect(created.provider_message_id).to eq('message-3')
end
end
