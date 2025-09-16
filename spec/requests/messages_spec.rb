require 'rails_helper'

RSpec.describe 'Messages API', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  it 'validates attachments type' do
    payload = {
      from: '+12016661234',
      to: '+18045551234',
      type: 'sms',
      body: 'Hello',
      attachments: { not: 'an array' },
      timestamp: '2024-11-01T14:00:00Z'
    }
    post '/api/v1/messages/sms', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:unprocessable_content).or have_http_status(:unprocessable_entity)
    expect(json).to eq('errors' => [{ 'field' => 'attachments', 'message' => 'Attachments must be an array of strings' }])
  end
  around do |ex|
    old = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    ex.run
  ensure
    ActiveJob::Base.queue_adapter = old
  end

  it 'sends an outbound SMS' do
    payload = {
      from: '+12016661234',
      to: '+18045551234',
      type: 'sms',
      body: 'Hello from SMS',
      attachments: nil,
      timestamp: '2024-11-01T14:00:00Z'
    }
    expect {
      post '/api/v1/messages/sms', params: payload.to_json, headers: headers
    }.to have_enqueued_job(SendMessageJob)
    expect(response).to have_http_status(:accepted)
    expect(response.media_type).to eq('application/json')
    expect_message_json(json, kind: 'sms', direction: 'outbound', from: payload[:from], to: payload[:to], status: 'queued', body: payload[:body], attachments: [])
    msg = Message.find(json['id'])
    expect(msg.kind).to eq('sms')
    expect(msg.direction).to eq('outbound')
    expect(msg.status).to eq('queued')
  end

  it 'sends an outbound MMS with attachment' do
    payload = {
      from: '+12016661234',
      to: '+18045551234',
      type: 'mms',
      body: 'Hello from MMS',
      attachments: ['https://example.com/image.jpg'],
      timestamp: '2024-11-01T14:00:00Z'
    }
    post '/api/v1/messages/sms', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:accepted)
    expect_message_json(json, kind: 'mms', direction: 'outbound', from: payload[:from], to: payload[:to], status: 'queued', body: payload[:body], attachments: payload[:attachments])
  end

  it 'sends an outbound Email' do
    payload = {
      from: 'user@usehatchapp.com',
      to: 'contact@gmail.com',
      body: 'Hello from Email',
      attachments: [],
      timestamp: '2024-11-01T14:00:00Z'
    }
    post '/api/v1/messages/email', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:accepted)
    expect_message_json(json, kind: 'email', direction: 'outbound', from: payload[:from], to: payload[:to], status: 'queued', body: payload[:body], attachments: payload[:attachments])
  end

  it 'validates kind for sms endpoint' do
    payload = {
      from: '+12016661234',
      to: '+18045551234',
      type: 'not-a-kind',
      body: 'Hello',
      attachments: [],
      timestamp: '2024-11-01T14:00:00Z'
    }
    post '/api/v1/messages/sms', params: payload.to_json, headers: headers
    expect(response).to have_http_status(:unprocessable_content).or have_http_status(:unprocessable_entity)
    expect(json).to eq('errors' => [{ 'field' => 'kind', 'message' => 'Kind is not included in the list' }])
end
end
