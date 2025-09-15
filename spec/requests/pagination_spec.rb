require 'rails_helper'

RSpec.describe 'Pagination', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  it 'paginates conversations with headers and links' do
    # Create 25 conversations
    25.times do |i|
      Conversation.find_or_create_by_participants("+1#{format('%010d', i)}", "+2#{format('%010d', i)}")
    end

    get '/api/v1/conversations', params: { page: 2, per_page: 10 }
    expect(response).to have_http_status(:ok)
    expect(response.headers['X-Page']).to eq('2')
    expect(response.headers['X-Per-Page']).to eq('10')
    expect(response.headers['X-Total-Pages']).to eq('3')
    expect(response.headers['X-Total-Count']).to eq('25')
    expect(response.headers['Link']).to include('rel="next"')
    expect(JSON.parse(response.body).length).to eq(10)
  end

  it 'paginates messages with headers and links' do
    conv = Conversation.find_or_create_by_participants('+10000000000', '+20000000000')
    120.times do |i|
      conv.messages.create!(kind: 'sms', direction: 'inbound', from_address: '+1', to_address: '+2', body: "msg #{i}")
    end

    get "/api/v1/conversations/#{conv.id}/messages", params: { page: 2, per_page: 50 }
    expect(response).to have_http_status(:ok)
    expect(response.headers['X-Page']).to eq('2')
    expect(response.headers['X-Per-Page']).to eq('50')
    expect(response.headers['X-Total-Pages']).to eq('3')
    expect(response.headers['X-Total-Count']).to eq('120')
    expect(response.headers['Link']).to include('rel="next"')
    expect(JSON.parse(response.body).length).to eq(50)
  end
end
