require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  it 'returns 404 JSON for missing conversation' do
    get '/api/v1/conversations/999999/messages'
    expect(response).to have_http_status(:not_found)
    expect(response.media_type).to eq('application/json')
    expect(json).to eq('error' => 'Conversation not found')
  end

  it 'returns 404 for unversioned route' do
    post '/api/messages/sms'
    expect(response.status).to eq(404)
  end
end

