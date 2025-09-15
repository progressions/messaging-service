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
    expect(response.status).to eq(422)
    expect(json['errors']).to be_an(Array)
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
    expect(json['kind']).to eq('sms')
    expect(json['direction']).to eq('outbound')
    expect(json['status']).to eq('queued')
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
    expect(json['kind']).to eq('mms')
    expect(json['attachments']).to be_an(Array)
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
    expect(json['kind']).to eq('email')
    expect(json['direction']).to eq('outbound')
    expect(json['status']).to eq('queued')
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
    expect(response.status).to eq(422)
    expect(json['errors']).to be_an(Array)
  end
end
