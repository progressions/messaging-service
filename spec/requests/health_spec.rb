require 'rails_helper'

RSpec.describe 'Health', type: :request do
  it 'returns ok' do
    get '/api/v1/health'
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include('status' => 'ok')
  end
end

